
# Contributed by John Mount jmount@win-vector.com , ownership assigned to Win-Vector LLC.
# Win-Vector LLC currently distributes this code without intellectual property indemnification, warranty, claim of fitness of purpose, or any other guarantee under a GPL3 license.

#' Map names of columns to known values and drop other columns.
#'
#' Used to restrict a data item's column names and re-name them in bulk.  Note: this can be expensive operation.
#'
#' Something like \code{replyr::replyr_mapRestrictCols} is only useful to get control of a function that is not parameterized
#' (in the sense it has hard-coded column names inside its implementation that don't the column names in our data).
#'
#' @seealso \code{\link{let}}
#'
#' @param x data item to work on
#' @param nmap named list mapping desired column names to column names in x. Doesn't support permutations of names.
#' @return data item with columns limitted down to those named in nmap, and re-named.
#'
#' @examples
#'
#' # an external function with hard-coded column names
#' DecreaseRankColumnByOne <- function(d) {
#'   d$RankColumn <- d$RankColumn - 1
#'   d
#' }
#'
#' # our example data, with different column names
#' d <- data.frame(Sepal_Length=c(5.8,5.7),Sepal_Width=c(4.0,4.4),
#'                 Species='setosa',rank=c(1,2))
#' print(d)
#'
#' # map our data to expected column names so we can use function
#' nmap <- c(GroupColumn='Species',
#'           ValueColumn='Sepal_Length',
#'           RankColumn='rank')
#' print(nmap)
#' dm <- replyr_mapRestrictCols(d,nmap)
#' print(dm)
#'
#' # can now apply code that expects hard-coded names.
#' dm <- DecreaseRankColumnByOne(dm)
#'
#' # map back to our original column names (for the columns we retained)
#' invmap <- names(nmap)
#' names(invmap) <- as.character(nmap)
#' print(invmap)
#' # Note: can only map back columns that were retained in first mapping.
#' replyr_mapRestrictCols(dm,invmap)
#'
#' @export
replyr_mapRestrictCols <- function(x,nmap) {
  nmap <- as.list(nmap)
  if(length(unique(nmap))!=length(nmap)) {
    stop("replyr::replyr_mapRestrictCols duplicate destination columns in replyr_mapRestrictCols")
  }
  if(length(unique(names(nmap)))!=length(nmap)) {
    stop("replyr::replyr_mapRestrictCols duplicate source columns in replyr_mapRestrictCols")
  }
  for(ni in names(nmap)) {
    if(!is.character(ni)) {
      stop('replyr::replyr_mapRestrictCols nmap keys must be strings')
    }
    if(length(ni)!=1) {
      stop('replyr::replyr_mapRestrictCols nmap keys must be strings')
    }
    ti <- nmap[[ni]]
    if(!is.character(ti)) {
      stop('replyr::replyr_mapRestrictCols nmap values must be strings')
    }
    if(length(ti)!=1) {
      stop('replyr::replyr_mapRestrictCols nmap values must be strings')
    }
    if(ti!=ni) {
      if(ti %in% names(nmap)) {
        stop("replyr::replyr_mapRestrictCols source and destination columns overlap in replyr_mapRestrictCols")
      }
    }
  }
  # limit down to only names we are mapping
  #do.call(dplyr::select_,c(list(x),as.list(names(nmap)))) -> x
  x %>% dplyr::select(dplyr::one_of(as.character(nmap))) -> x
  # re-map names
  for(ni in names(nmap)) {
    ti <- nmap[[ni]]
    if(ti!=ni) {
      x %>% dplyr::rename_(.dots=stats::setNames(ti,ni)) -> x
    }
  }
  x
}