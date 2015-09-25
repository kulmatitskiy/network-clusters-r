library(MCMCpack) # for dirichlet sampling
source("local.steepest.ascent.R")

# Sampling methods for random group vectors

sample.groups.uniform <- function(N, group.choices, prev.groups = NULL) {
  return(sample(group.choices, N, replace = TRUE))
}

sample.groups.dirichlet <- function (N, group.choices, prev.groups = NULL) {
  return(sample(group.choices, N, replace = TRUE, prob = rdirichlet(1, rep(2, length(group.choices)))))
}

# sample_groups_lognormal = function(N, group.choices, prev.groups = NULL) {
#     # # # # Not implemented # # # # 
# }


# The Algorithm

global.steepest.ascent <- function (objective.matrix, max.groups, trials = 10, reference.groups = NULL,
                                   details = FALSE, generator = sample.groups.dirichlet, seed = NULL) 
{
  # Performs global steepest ascent optimization by sampling starting points from the provided 'generator' function.
  #
  # Required Args:
  #   objective.matrix: Objective Matrix for which optimal group vector should be found (see README)
  #   max.groups: Maximum number of groups to use in the group vector.
  #   trials: Number of trials.
  # Optional Args:
  #   reference.groups: a vector of length N with values in 1:max.groups that results
  #                     will be compared to
  #   details: boolean flag to provide details or not
  #   generator: function(N, group.choices, prev.groups = NULL) used to generate
  #              a starting point for next trial
  #   
  # Returns:
  #   list object with various results of the algorithm
  
  # Start with some preparations
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

  # Actual search loop begins here
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
  
  # Done; Prepare return list
  ret.list <- list(groups = best.groups, obj.value = best.obj.value)
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

# 
# global_ascent_stage = function(objective_matrix, G, trials = 10, timed = FALSE){
#     group_choices = 1:G
#     N = nrow(objective_matrix)
#     best_objective = -Inf
#     promised <<- c()
#     features <<- c()
#     for(t in 1:trials){
#         groups = sample(group_choices, N, replace = TRUE)
#         features_tmp = c()
#         while(TRUE){
#             C = comembership_matrix(groups)
#             sizes = unique(rowSums(C))
#             BC = objective_matrix %*% comembership_matrix(groups)
#             D = BC - diag(BC)
#             if(any(D > 0)){
#                 features_tmp = rbind(features_tmp, c(foo(groups, G)))
#                 groups = switch_groups_by_D(D, max(D), groups)
#             }else{
#                 features <<- rbind(features, features_tmp)
#                 promised <<- c(promised, rep(sum(diag(BC)), length.out = nrow(features_tmp)))
#                 break
#             }
#         }
#     }
# }