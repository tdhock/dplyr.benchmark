#DPLYR_URL <- "https://github.com/hadley/dplyr.git"
DPLYR_URL <- "../dplyr"

dplyr_repo_ <- function() {
  temp_dir <- tempfile("dplyr")

  system2("git", c("clone", shQuote(DPLYR_URL), "--bare", "--mirror",
                   shQuote(temp_dir)))

  git2r::repository(temp_dir)
}

#' @export
dplyr_repo <- memoise::memoise(dplyr_repo_)

#' @export
get_log_df <- function(ref = "master", repo = dplyr_repo()) {
  log <- get_log(ref, repo)
  log_to_df(log)
}

# git2r::commits() doesn't report time
get_log <- function(ref, repo) {
  withr::with_dir(repo@path, {
    system2("git", c("log --format='%H %aI' --first-parent", ref,
                     "--", "src", "inst/include"),
            stdout = TRUE)
  })
}

log_to_df <- function(log) {
  log %>%
    rev %>%
    strsplit(" ", fixed = TRUE) %>%
    purrr::transpose() %>%
    `names<-`(c("sha", "commit_time")) %>%
    lapply(unlist) %>%
    as_data_frame %>%
    mutate(commit_time = as.POSIXct(commit_time)) %>%
    mutate(commit_id = seq_along(commit_time))
}