# Helper functions, largely for model state management
# ----------------------------------------------------

PCS_memory_create <- function(nodes, node_names=NULL) {
  if (is.null(node_names)) {
    node_names = paste("node_", 1:nodes, sep="")
  }
  memory <- matrix(ncol=2+nodes, nrow=100)
  colnames(memory) <- c("iteration", "energy", node_names)
  return(memory)
}

PCS_memory_needs_expansion <- function(memory, iteration) {
  return(iteration + 1 == nrow(memory))
}

PCS_matrix_expand <- function(ma, iteration) {
  if (PCS_memory_needs_expansion(ma, iteration)) {
    return(
      rbind(ma, matrix(ncol=ncol(ma), nrow=100))
    )
  } else {
    return(ma)
  }
}

PCS_matrix_trunc <- function(x) {
  return(x[!is.na(x[,1]), , drop=F])
}
