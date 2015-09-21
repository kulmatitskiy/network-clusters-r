source("common.R")

switch.groups <- function(groups, D) {
  coord <- which(D == max(D), arr.ind=TRUE)[1,] # Note: it is suboptimal to find max and index_max in two separate steps
  groups[coord[1]] <- groups[coord[2]]
  return(groups)
}

# perform steepest ascent algorithm locally starting with provided groups vector
local.steepest.ascent <- function(objective.matrix, groups, store.trace = FALSE, trace.apply.fun = NULL) {
  trace.group.counts <- c(); 
  trace.obj.values <- c(); 
  trace.apply.values <- c()
    
  while(TRUE) {
      # 1. Compute 'Differential Matrix' D as defined in README.MD
      BC <- objective.matrix %*% comembership.matrix(groups)
      D <- BC - diag(BC)
      obj.value <- sum(diag(BC))
      
      # store trace data if needed
      if (store.trace) {
        trace.obj.values <- c(trace.obj.values, obj.value)
        trace.group.counts <- c(trace.group.counts, length(unique(groups)))
        if (!is.null(trace.apply.fun)) {
          trace.apply.values <- c(trace.apply.values, trace.apply.fun(groups))
        }
      }
      
      # 2. In any positive differential D[i,j] is found, switch group memberships
      if (any(D > 0)) {
        groups <- switch.groups(groups, D)
      } else {
        break
      }
  }
  
  ret.list <- list(
    groups = groups,
    D = D,
    obj.value = obj.value
  )
  if (store.trace) {
    ret.list$trace.obj.values <- trace.obj.values
    ret.list$trace.group.counts <- trace.group.counts
    ret.list$trace.apply.values <- trace.apply.values
  }
  return(ret.list)
}