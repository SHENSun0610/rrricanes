#' @title extract_product_contents
#' @description Get and parse product contents for each links
#' @param links URLs to storm products
#' @param product specific product to parse
#' @param p dplyr::progress_estimated object
#' @keywords internal
extract_product_contents <- function(links, product, p) {

  p$pause(0.5)$tick()$print()

  res <- purrr::map(links, get_url_contents) %>% purrr::flatten()

  res_parsed <- purrr::map(res, ~xml2::read_html(.$content)) %>%
  purrr::map(.f = function(x) {
    if (is.na(txt <- rvest::html_node(x, xpath = "//pre") %>%
        rvest::html_text()))
    txt <- rvest::html_text(x)
    return(txt)
  })

  df <- purrr::invoke_map_df(product, .x = res_parsed)

  return(df)

}

#' @title extract_storm_links
#' @description Extract product links from a storm's archive page
#' @param links URLs to a storm's archive page
#' @param p dplyr::progress_estimated object
#' @keywords internal
extract_storm_links <- function(links, p) {

  if (p$i > 0) p$pause(0.5)
  p$tick()$print()

  res <- purrr::map(links, .f = function(x) {get_url_contents(x)}) %>%
  purrr::flatten()

  # Get contents of all storms
  storm_contents <- purrr::map(res, ~.$parse("UTF-8")) %>%
  purrr::map(xml2::read_html)

  years <- purrr::map(res, ~.$url) %>%
  purrr::flatten_chr() %>%
  stringr::str_extract("[[:digit:]]{4}") %>%
  as.numeric()

  # Extract all links
  product_links <- purrr::map(storm_contents,
                ~rvest::html_nodes(x = .x, xpath = "//td//a")) %>%
  purrr::map(~rvest::html_attr(x = .x, name = "href"))

  # 1998 product links are relative and prefixed with "/archive/1998/" whereas
  # other years, product_links are absolute. If product_links exist for 1998
  # they must be modified. After, all product_links must be prefixed with
  # nhc_domain
  nhc_domain <- get_nhc_link(withTrailingSlash = FALSE)
  product_links[years == 1998] <- purrr::map(product_links[years == 1998],
                       ~sprintf("/archive/1998/%s", .))
  product_links <- purrr::map(product_links, ~sprintf("%s%s", nhc_domain, .))
  return(product_links)
}

#' @title get_storm_content
#' @description Extract content from a storm's archive page
#' @param link of archive page
#' @return page content of archive page
#' @keywords internal
get_storm_content <- function(link) {
  contents <- get_url_contents(link) %>% rvest::html_nodes(xpath = "//td//a")
  return(contents)
}

#' @title get_storm_data
#' @description Retrieve data from products.
#' @details \code{get_storm_data} is a wrapper function to make it more
#'   convenient to access the various storm products.
#'
#' Types of products:
#' \describe{
#'   \item{discus}{Storm Discussions. This is technical information on the
#'   cyclone such as satellite presentation, forecast model evaluation, etc.}
#'   \item{fstadv}{Forecast/Advisory. These products contain the meat of an
#'   advisory package. Current storm information is available as well as
#'   structural design and forecast data.}
#'   \item{posest}{Position Estimate. Issued generally when a storm is
#'   threatening; provides a brief update on location and winds.}
#'   \item{public}{Public Advisory. Issued for public knowledge; more often for
#'   Atlantic than East Pacific storms. Contains general information.}
#'   \item{prblty}{Strike Probability. Discontinued after the 2005 hurricane
#'   season, strike probabilities list the chances of x-force winds in a
#'   particular city.}
#'   \item{update}{Cyclone Update. Generally issued when a significant change
#'   occurs in the cyclone.}
#'   \item{windprb}{Wind Probability. Replace strike probabilities beginning in
#'   the 2006 season. Nearly identical.}
#' }
#'
#' Progress bars are displayed by default. These can be turned off by setting
#' the dplyr.show_progress to FALSE. Additionally, you can display messages for
#' each advisory being worked by setting the rrricanes.working_msg to TRUE.
#'
#' @param links to storm's archive page.
#' @param products Products to retrieve; discus, fstadv, posest, public,
#'   prblty, update, and windprb.
#' @return list of dataframes for each of the products.
#' @examples
#' \dontrun{
#' ## Get public advisories for first storm of 2016 Atlantic season.
#' get_storms(year = 2016, basin = "AL") %>%
#'   slice(1) %>%
#'   .$Link %>%
#'   get_storm_data(products = "public")
#' ## Get public advisories and storm discussions for first storm of 2017 Atlantic season.
#' get_storms(year = 2017, basin = "AL") %>%
#'   slice(1) %>%
#'   .$Link %>%
#'   get_storm_data(products = c("discus", "public"))
#' }
#' @export
get_storm_data <- function(links, products = c("discus", "fstadv", "posest",
                        "public", "prblty", "update",
                        "wndprb")) {

  products <- match.arg(products, several.ok = TRUE)

  # There is an 80-hit/10-second limit to the NHC pages (#94), or 8
  # requests/second. The below request will process 4 links every 0.5 seconds.
  links <- split(links, ceiling(seq_along(links)/4))

  # Set progress bar
  p <- dplyr::progress_estimated(n = length(links))

  if (getOption("rrricanes.working_msg"))
  message("Gathering storm product links.")

  storm_links <- purrr::lmap(links, extract_storm_links, p)

  # Filter links based on products and make one-dimensional
  product_links <- purrr::invoke_map(.f = sprintf("filter_%s", products),
                   .x = list(list(links = storm_links))) %>%
  purrr::map(purrr::flatten_chr)

  names(product_links) <- products

  # Loop through each product getting link contents
  if (getOption("rrricanes.working_msg"))
  message("Working individual products.")

  # group links by products
  grouped_links <- purrr::map(product_links, ~split(., ceiling(seq_along(.)/4)))

  # set progress based on grouped_links
  p <- dplyr::progress_estimated(sum(purrr::map_int(grouped_links, length)))

  ds <- purrr::map(products, .f = function(x) {
  df <- purrr::map_df(grouped_links[[x]], extract_product_contents, x, p) %>%
    dplyr::arrange(Date)
  })

  names(ds) <- products

  return(ds)
}
