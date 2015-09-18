library(MCMCpack) # for dirichlet sampling
source("local.steepest.ascent.R")

# Sampling methods for random group vectors

sample.groups.uniform <- function(N, group.choices, prev.groups = NULL) {
  return(sample(group.choices, N, replace = TRUE))
}

sample.groups.dirichlet <- function (N, group.choices, prev.groups = NULL) {
  return(sample(group.choices, N, replace = TRUE, prob = rdirichlet(1, rep(2,length(group.choices)))))
}

# sample_groups_lognormal = function(N, group.choices, prev.groups = NULL) {
#     # # # # Not implemented # # # # 
# }

global.steepest.ascent = function (objective.matrix, max.groups, trials = 10, reference.groups = NULL,
                                   details = FALSE, generator = sample.groups.dirichlet, seed = NULL) 
{
  # begine with some preparations
  if (!is.null(seed)) {
    set.seed(seed)
  }
    
  group.choices <- 1:max.groups
  N <- nrow(objective.matrix)
  
  if (details) {
    ptm <- proc.time()
    hits <- c(0)
    waiting.times <- c(0)
  }
  
  best.obj.value <- -Inf
  best.groups <- rep(1, max.groups)
  reference.obj.value <- -Inf
  
  if (!is.null(reference.groups)) {
    tmp <- local.steepest.ascent(objective.matrix, reference.groups)
    best.obj.value <- tmp$obj.value
    best.groups <- tmp$groups
    reference.obj.value <- tmp$obj.value
  }

  # actual search loop begins here
  groups <- generator(N, group.choices, NULL)
  for (t in 1:trials) {
    tmp <- local.steepest.ascent(objective.matrix, groups)
    # print(tmp$obj.value)
    if (tmp$obj.value > best.obj.value) {
        best.obj.value <- tmp$obj.value
        best.groups <- tmp$groups
        
        if (details) {
          waiting.times <- c(waiting.times, ifelse(length(hits)==0, t, t - hits[length(hits)]))
          hits <- c(hits, t);
        }
    }
    if (t != trials) {
      groups <- generator(N, group.choices, group)
    }
  }
  
  # prepare return list
  ret.list = list(groups = best.groups, obj.value = best.obj.value)
  if (details) {
    ret.list$time <- proc.time() - ptm
    if (!is.null(reference.groups)) {
        ret.list$reference.obj.value <- reference.obj.value
    }
    ret.list$hits <- hits
    waiting.times <- c(waiting.times, trials - hits[length(hits)])
    ret.list$trials.summary <- data.frame(trials = trials, hits = length(hits), 
                                          misses = trials - length(hits), hit.rate = length(hits) / trials,
                                          average.wait = mean(waiting.times))
    if (!is.null(seed)) {
      ret.list$seed <- seed
    }
  }
  return(ret.list)
}
