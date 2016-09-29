# This test compares the package output to a known result based on previous
# simulation code by Marc Jekel (in R) and Felix Henninger (in Python). The one
# known difference is that the previously available code (falsely) always takes
# exactly one more iteration.

# Build the model specified by Glöckner & Betsch, 2008
nodes = 7

# Specify state and resting levels
resting_levels <- rep(0, nodes)
state <- rep(0, nodes)
reset <- c(1, rep(0, nodes - 1))

node_names <- c("sourceNode", "cue 1", "cue 2", "cue 3", "cue 4",
                "option 1", "option 2")

# Build the interconnection matrix
interconnection_matrix <- matrix(rep(0, nodes^2), nrow=nodes)

interconnection_matrix[1, 2] = 0.8
interconnection_matrix[1, 3] = 0.7
interconnection_matrix[1, 4] = 0.6
interconnection_matrix[1, 5] = 0.55

# Do validity transformations
sourceNodeCueW <- interconnection_matrix[1,2:5]
sourceNodeCueW_sign = sign(sourceNodeCueW)
sourceNodeCueW = ((abs(sourceNodeCueW) - 0.5) * 1) ** 1.9
interconnection_matrix[1,2:5] = sourceNodeCueW * sourceNodeCueW_sign

# Do cue value transformations
cueOptionScale = 0.01

interconnection_matrix[2, 6] =  1 * cueOptionScale
interconnection_matrix[3, 6] =  1 * cueOptionScale
interconnection_matrix[4, 6] =  1 * cueOptionScale
interconnection_matrix[5, 6] = -1 * cueOptionScale

interconnection_matrix[2, 7] = -1 * cueOptionScale
interconnection_matrix[3, 7] = -1 * cueOptionScale
interconnection_matrix[4, 7] = -1 * cueOptionScale
interconnection_matrix[5, 7] =  1 * cueOptionScale

# Set the option-to-option inhibition
interconnection_matrix[6, 7] = -0.2

# Make the interconnection matrix symmetrical
interconnection_matrix <- interconnection_matrix +
  t(upper.tri(interconnection_matrix) * interconnection_matrix)
interconnection_matrix <- matrix(interconnection_matrix, nrow=nodes)

test_that('the convergence criteria correspond to earlier calculations', {

  output <- PCS_run(
    interconnection_matrix, state, resting_levels, reset,
    node_names=node_names
    )

  expect_equal(
    output$convergence,
    setNames(c(116), c('criterion_1'))
  )

})

test_that('the energy after convergence corresponds to earlier simulations', {
  output <- PCS_run_from_interconnections(interconnection_matrix)
  expect_equal(
    round(output$iterations[nrow(output$iterations), 'energy'], 6),
    round(-0.29164326, 6)
  )
})
