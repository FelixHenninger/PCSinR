#' Simulate the run of a PCS model
#'
#' \code{PCS_run} simulates a PCS network given a pre-specified interconnection
#' matrix and model parameters, according to the mechanism outlines by
#' McClelland and Rumelhart (1981).
#'
#' @param interconnection_matrix A square, matrix representing the link weights
#'   between nodes, such that each entry w_ij represents the link strength
#'   between nodes i and j. Accordingly, for a network of n nodes, the matrix
#'   must be of six n*n. In most applications, the matrix will be symmetric,
#'   meaning that links are bidirectional.
#'
#' @param initial_state Initial node activations before the first iteration is
#'   run. In most cases, this will be a vector of zeros, with the length
#'   corresponding to the number of nodes in the network.
#'
#' @param resting_levels Resting activation level for each node. In most cases,
#'   this will be a vector of zeros, with its length corresponding to the number
#'   of nodes in the network.
#'
#' @param reset Vector denoting nodes with stable activation values. The vector
#'   contains a value for each node; if it is unequal to zero, the node
#'   activation will be reset to this value after each iteration.
#'
#' @param node_names Vector specifying human-readable labels for every node, or
#'   \code{'default'}, in which case nodes are automatically named.
#'
#' @param stability_criterion Stability theshold for convergence criteria. If
#'   energy changes across iterations fall below this threshold, the model is
#'   considered to have converged.
#'
#' @param max_iterations Maximum number of iterations to run before terminating
#'   the simulation.
#'
#' @param convergence_criteria Array of convergence criteria to apply. This PCS
#'   implementation allows users to define and observe multiple convergence
#'   criteria in one model. Each entry in this array is a convergence criterion,
#'   which is representated as a function that receives the current iteration,
#'   energy, model state history and the \code{stability_criterion} defined
#'   above and returns a boolean value representing whether the particular
#'   criterion is met given the model's current state.
#'
#' @param convergence_names Human-readable labels for the convergence criteria,
#'   or \code{'default'}, in which case the criteria are numbered automatically,
#'   in which case the criteria are numbered automatically.
#'
#' @return A list representing the model state after all convergence criteria
#'   have been fullfilled. The key \code{iterations} contains the model state
#'   over its entire run, while the key \code{convergence} defines which
#'   convergence criteria have been met at which iteration. Together, these
#'   provide an exhaustive summary of the model's behavior.
#'
#' @export
PCS_run <- function(interconnection_matrix, initial_state, resting_levels, reset,
                    node_names=NULL, stability_criterion=10^-6, max_iterations=Inf,
                    convergence_criteria=c(PCS_convergence_McCandR), convergence_names=NULL) {
  # A note on the iteration counter:
  # The counter reflects the current line of the
  # model output, but the iterations start at zero.
  # Therefore, whenever iterations are output,
  # one is subtracted from this counter.
  #
  # This may seem silly, but it makes sense because
  # a) It is equivalent to the python output
  # b) The first output is not actually from the
  #    first iteration, rather nothing has happened
  #    at that point.
  iteration <- 1

  # How many convergence criteria are going to be
  # applied?
  n_criteria <- length(convergence_criteria)

  # Name the criteria, if that has not already happened
  if (is.null(convergence_names)) {
    convergence_names <- paste("criterion_", 1:n_criteria, sep="")
  }

  # Initialize the model state
  state <- initial_state
  state <- PCS_reset(state, reset)
  nodes <- length(state)
  energy <- PCS_energy(interconnection_matrix, state)

  # Create the matrix in which we will save
  # the data from the model iterations
  memory.ma <- PCS_memory_create(nodes, node_names)
  memory.ma[iteration,] <- c(iteration-1, energy, state)

  # Create the matrix in which we will save
  # convergence data
  convergence.ma <- matrix(ncol=n_criteria, nrow=nrow(memory.ma))
  colnames(convergence.ma) <- convergence_names
  convergence.ma[1, ] <- TRUE

  # This is the main model evaluation loop
  continue = TRUE
  while (continue == TRUE & iteration <= max_iterations) {
    # Increment the counter
    iteration = iteration + 1

    # Compute the new model state and energy
    state <- PCS_iterate(interconnection_matrix, state, resting_levels)[1:nodes]
    state <- PCS_reset(state, reset)
    energy <- PCS_energy(interconnection_matrix, state)

    # Write the current state into the matrix
    memory.ma[iteration, ] <- c(iteration-1, energy, state)

    # Expand the output matrix if necessary
    if (PCS_memory_needs_expansion(memory.ma, iteration)) {
      memory.ma <- PCS_matrix_expand(memory.ma, iteration)
      convergence.ma <- PCS_matrix_expand(convergence.ma, iteration)
    }

    # Check if the model has converged yet, using
    # the given criterion functions
    for (f in 1:n_criteria) {
      convergence.ma[iteration, f] <- convergence_criteria[[f]](
        iteration=iteration,
        current_energy=energy,
        memory.matrix=memory.ma,
        stability_criterion=stability_criterion,
      )
    }

    # Continue until all criteria are converged
    continue <- (sum(convergence.ma[iteration,] * 1) > 0)
  }

  # Prepare and pass along the model output
  memory.ma <- PCS_matrix_trunc(memory.ma)
  memory.df <- as.data.frame(memory.ma)

  convergence.ma <- PCS_matrix_trunc(convergence.ma)

  output <- list()
  output$iterations <- memory.df

  # Note that the MPI Coll implementation will always assume
  # one more iteration. To match their simulations,
  # add "+ 1" in the next line
  output$convergence <- colSums(convergence.ma)

  return(output)
}

#' Simulate the run of a PCS model based on only the interconnection matrix
#'
#' \code{PCS_run_from_interconnections} simulates a PCS network given
#' \emph{only} the pre-specified interconnection matrix and convergence
#' criteria, substituting default values from the literature for all other
#' parameters. Thereby, it provides a convenient shorthand for the
#' \code{\link{PCS_run}} function that covers the vast majority of applications.
#'
#' @inheritParams PCS_run
#'
#' @examples
#'
#' # Build interconnection matrix
#' interconnections <- matrix(
#'   c( 0.0000,  0.1015,  0.0470,  0.0126,  0.0034,  0.0000,  0.0000,
#'      0.1015,  0.0000,  0.0000,  0.0000,  0.0000,  0.0100, -0.0100,
#'      0.0470,  0.0000,  0.0000,  0.0000,  0.0000,  0.0100, -0.0100,
#'      0.0126,  0.0000,  0.0000,  0.0000,  0.0000,  0.0100, -0.0100,
#'      0.0034,  0.0000,  0.0000,  0.0000,  0.0000, -0.0100,  0.0100,
#'      0.0000,  0.0100,  0.0100,  0.0100, -0.0100,  0.0000, -0.2000,
#'      0.0000, -0.0100, -0.0100, -0.0100,  0.0100, -0.2000,  0.0000 ),
#'   nrow=7
#'   )
#'
#' # Run model
#' result <- PCS_run_from_interconnections(interconnections)
#'
#' # Examine iterations required for convergence
#' result$convergence
#'
#' # Examine final model state
#' result$iterations[nrow(result$iterations),]
#'
#' @export
PCS_run_from_interconnections <- function(interconnection_matrix,
  convergence_criteria=c(PCS_convergence_McCandR), convergence_names="default") {
  # This function is just a simplification to speed up my work

  # Infer the number of nodes from the matrix size
  nodes <- nrow(interconnection_matrix)

  # This function assumes that the initial state,
  # as well as the resting levels, are all set to zero
  resting_levels <- rep(0, nodes)
  state <- rep(0, nodes)

  # We assume that the first node (and only that)
  # has a constant activation
  reset <- c(1, rep(0, nodes - 1))

  # Good to go! :-)
  return(PCS_run(interconnection_matrix, state, resting_levels, reset,
                 convergence_criteria=convergence_criteria, convergence_names=convergence_names))
}
