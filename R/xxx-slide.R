#' Get contents of a layout file
#'
#' Returns the contents as-is, if the layout does not inherit from a parent.
#' If it inherits from a parent, then the {{{ content }}} portion of the parent
#' layout is replaced by the contents of the layout file and the resulting
#' layout is returned. This is useful for template inheritance.
#'
#'
get_layout <- function(lname){
  tpath <- file.path('assets', 'templates', sprintf('%s.tpl', lname))
  tpl  <- read_file(tpath)
  mpat <- "^---\nlayout: ([[:alpha:]]+)\n---\n(.*)$"
  has_parent <- grepl(mpat, tpl)
  if (has_parent){
    main  <- gsub(mpat, '\\1', tpl)
    mpath <- file.path('assets', 'templates', sprintf('%s.tpl', main))
    main  <- read_file(mpath)
    content <- gsub(mpat, "\\2", tpl)
    tpl <- sub("{{{ content }}}", content, main, fixed = TRUE)
  }
  return(tpl)
}

#' Render contents of a slide based on template
#' 
#' @keywords internal
render_slide <- function(slide){
  if (length(slide$tpl) == 0){
    slide$tpl <- 'slide'
  } 
  tpl <- get_layout(slide$tpl)
  slide$slide <- whisker.render(tpl, slide)
  return(slide)
}

#' Remove hidden slides marked with the class "hidden"
#'
#' @keywords internal
#  Thanks to Kohske
remove_hidden_slides <- function(slides){
  slide_classes = lapply(slides, function(x) x$classes)
  hidden_slides = grep('hidden', slide_classes)
  if (length(hidden_slides) > 0){
    slides[-hidden_slides]
  } else {
    slides
  }
}

#' Add slide numbers to the slides
#'
#' @keywords internal
add_slide_numbers <- function(slides){
  for (i in seq_along(slides)){
    slides[[i]]['num'] <- i
  }
  return(slides)
}

#' Add ids for slides with no defaults
#'
#' @keywords internal
add_missing_id <- function(slides){
  for (i in seq_along(slides)){
    if (length(slides[[i]]$id) == 0){
      slides[[i]]['id'] = sprintf("slide-%s", i)
    }
  }
  return(slides)
}

#' Add raw R markdown source to slide vars
#
# TODO: Remove preceding newlines to optimize display of source code.
add_raw_rmd <- function(slides, source){
  raw_rmd <- doc2slides(source)
  for (i in seq_along(slides)){
    slides[[i]]['raw'] <- paste(raw_rmd[[i]][-1], collapse = "\n")
  }
  return(slides)
}

# REFACTORING IDEA
# There is a design pattern in all of the add_*_* functions.