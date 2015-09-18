library(MCMCpack)

comembership.matrix <- function(groups) {
  C <- matrix(as.numeric((groups%o%(1/groups))==1), ncol=length(groups), nrow=length(groups))
  return(C)
}
#g_to_C = comembership_matrix #alias for the above

# C_to_g = function(C){
#   N = nrow(C)
#   groups = 0*(1:N)
#   nodes = 1:N
#   g = 1
#   while(nrow(C) > 0){
#     ind = which(C[1,]==1)
#     groups[nodes[ind]] = g
#     C = as.matrix(C[-ind, -ind])
#     nodes = nodes[-ind]
#     g = g+1
#   }
#   return(groups)
# }
# 
# diff_matrix = function(objective_matrix, groups){
#   D = modularity_matrix %*% objective_matrix(groups)
#   return(D - diag(D))
# }
# 
# compute_objective = function(objective_matrix, groups){
#   return(0.5*sum(objective_matrix*comembership_matrix(groups)))
# }
# 
# test_group_equality = function(groups1, groups2){
#   return(all(g_to_C(groups1) == g_to_C(groups2)))
# }
# 
# RAND = function(groups1, groups2){
#   N = length(groups1)
#   if(N != length(groups2))
#     stop("Cannot compute RAND for partitions vectors of different lengths.")
#   return((sum(g_to_C(groups1)==g_to_C(groups2))-N)/(N*(N-1)))
# }