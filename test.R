library(igraph) # to read
source("global.steepest.ascent.R")

# compute Chung Lu probability estimates for the adjacency matrix X
ChungLuPNull <- function(X) {
  N <- nrow(X);
  P_null <- mat.or.vec(N,N)
  k <- rowSums(X)
  M <- sum(k) / 2
  P_null <- k %*% t(k) / (2*M)
  out_of_bound <- (P_null > 1)
  P_null[out_of_bound] <- 0.9999
  if(any(out_of_bound))
    cat("\nThere were instances of out-of-bound probabilities.\n")
  diag(P_null) <- 0
  return(P_null)
}

filename <- "example_datasets/dolphins.gml"
is.gml <- TRUE

if (is.gml) {
  Gdata <- read.graph(filename, format = "gml")
  X <- as.matrix(get.adjacency(Gdata, type = "both"))
}
N <- nrow(X)


group.count <- 10
trials <- 100
result <- global.steepest.ascent(X - ChungLuPNull(X), group.count, trials = trials, details = TRUE)