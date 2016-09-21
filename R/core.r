# PCS core functions
# ------------------
#
# This file containes the core model functions, which govern its
# behavior. It is not made directly available to end-users, who
# access it through the PCS_run API

# Calculate a new state given an interconnection matrix and
# aprevious state.
PCS_iterate <- function(interconnection_matrix, state, resting_levels,
  decay_rate=0.1, floor=-1, ceiling=1) {

  # Start from a base state
  active_nodes <- state

  # Calculate the net inputs as a weighted sum
  # across the matrix
  net_inputs <- active_nodes %*% t(interconnection_matrix)

  # Calculate the change based on the net inputs
  change <- (net_inputs >= 0) * net_inputs * (ceiling - state) +
    (net_inputs < 0) * net_inputs * (-floor + state)

  # Calculate node decay
  decay <- decay_rate * (state - resting_levels)

  # Return updated state
  return(state - decay + change)
}

# Calculate the energy present in a model, given an interconnection
# matrix and a current state
PCS_energy <- function(interconnection_matrix, state) {
  return(
    -1 * sum((state %*% interconnection_matrix) %*% state)
  )
}

# Given a state and a vector of values to reset nodes to,
# reset node states where the reset criterion is not zero
PCS_reset <- function(state, reset) {
  return(
    (reset != 0) * reset + (reset == 0) * state
  )
}
