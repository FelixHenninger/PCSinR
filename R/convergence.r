#' Check a PCS network for convergence
#'
#' This function applies the convergence criterion defined by McClelland and
#' Rumelhart to a given network, and returns either a (qualitative) boolean
#' value that represents the convergence state, or a (quantitative) value that
#' represents the number of iterations (of the last 10) that have met the
#' convergence threshold.
#'
#' The check requires the following parameters:
#'
#' @param iteration The iteration to consider -- in most cases, this will be the
#'   current iteration during a simulation run, however, the check can also be
#'   applied to a model output retroactively, and the iteration specified
#'   manually.
#'
#' @param current_energy The current energy level within the network
#'
#' @param memory.matrix A matrix of iteration, energy and node states (in
#'   columns, in that order), across all previous iterations (in rows).
#'
#' @param stability_criterion Criterion for stability. Changes below this value
#' are no longer considered significant, and ten iterations without significant changes
#' to the energy level in succession will trigger the convergence check.
#'
#' @param output Either \code{'qualitative'} (default), in which case the check
#'   returns a boolean value representing whether it has passed or not, or
#'   \code{'quantitative'}, in which case the number of checked trials for which
#'   the convergence criterion was met is returned. This last option is of most
#'   value for debugging convergence.
#'
#' @export
PCS_convergence_McCandR <- function(iteration, current_energy, memory.matrix,
                                    stability_criterion=10^-6, output="qualitative") {
  # Felix' interpretation of the McClelland & Rumelhart criterion
  if (iteration <= 10) {
    return(TRUE)
  } else {
    # Convergence stops if the change in energy between iterations
    # is below a certain threshold for > 10 trials
    energy_changes <- memory.matrix[(iteration-10):(iteration-1), 2] -
                      memory.matrix[(iteration-9):(iteration), 2]
    changes_below_threshold <- sum(energy_changes < stability_criterion)

    if (output == "quantitative") {
      return(changes_below_threshold)
    } else {
      return(changes_below_threshold < 10)
    }
  }
}
