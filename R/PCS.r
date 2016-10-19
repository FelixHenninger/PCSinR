#' PCS: Parallel Constraint Satisfaction networks in R
#'
#' The PCS package contains all necessary functions for building and simulation
#' Parallel Constraint Satisfaction (PCS) network models within R.
#'
#' \emph{PCS models} are an increasingly used framework throughout psychology:
#' They provide quantitative predictions in a variety of paradigms, ranging from
#' word and letter recognition, for which they were originally developed
#' (McClelland & Rumelhart, 1981; Rumelhart & McClelland, 1982), to complex
#' judgments and decisions (Glöckner & Betsch, 2008; Glöckner, Hilbig, & Jekel,
#' 2014), and many other applications besides.
#'
#' @section Theoretical overview:
#'
#'   PCS networks embody the concept of \emph{consistency maximization} in
#'   perception and cognition, in that they assume that a cognitive system will
#'   attempt to achieve a coherent state, in which all available information is
#'   weighted to provide a maximally consistent representation of a given task.
#'   Their central qualitative prediction follows from this basic assumption,
#'   namely that the weights assigned to available information are reevaluated
#'   during the decision process. These coherence shifts are a unique prediction
#'   of PCS models, and have been found in multiple domains (c.f. Glöckner,
#'   Betsch, & Schindler, 2010; Holyoak & Simon, 1999, Simon & Holyoak, 2002).
#'
#'   PCS models are implemented as neural networks, though they do not assume a
#'   direct mapping from model nodes and connections onto neurons and dendrites.
#'   Instead, the \emph{nodes} represent concepts, and the \emph{links} between
#'   them the degree to which the concepts are compatible or reconcilable. The
#'   assumption is that a PCS network is instantiated whenever a decision maker
#'   faces a choice (Glöckner & Betsch, 2008).
#'
#'   At any given time, a node exhibits a certain level of \emph{activation},
#'   which it passes through any present links to other nodes. If the level is
#'   positive, the node is activated, otherwise it is labelled inhibited.
#'   Activation is passed between nodes along the links, to varying degrees
#'   depending on their strength and nature, which determines the spread of
#'   activation in the network. Links can be excitatory, in that an activated
#'   node on one side leads to an increasing activation of any connected node,
#'   or inhibitory, in which connected nodes assume the opposite activation
#'   level. Thus, nodes can be mutually supportive regarding their level of
#'   activation, or restrain one another. Besides this qualitative difference,
#'   links also differ in their weight, a number which denotes the proportion of
#'   activation that is passed along the link. A link's magnitude captures the
#'   connection weight, and its sign the qualitative type of influence
#'   (excitatory or inhibitory). Links are always bidirectional, in that both
#'   nodes reciprocally influence one another, in the same manner and to the
#'   same extent.
#'
#'   Within the network, processing occurs in discontinuous cycles,
#'   \emph{iterations}. In each cycle anew, nodes pass a proportion of their
#'   activation level along the links to connected siblings. At each receiving
#'   node, the total arriving activation is termed the total input. Because the
#'   amount of activation passed through a link is multiplied by the link
#'   weight, the total input is a weighted sum of the activation of all
#'   connected nodes. The input does not, however, influence the node directly,
#'   but instead is subject to two additional influences: First, the activation
#'   of each node is reduced by a fixed proportion at each iteration, so that
#'   the activation level \emph{decays} to a fixed neutral point. Second, the
#'   current activation level of the node determines the influence of the
#'   arriving input: A node that is already active is less susceptible to
#'   further excitatory input, and more so to external inhibition. The converse
#'   holds for an inhibited node: Excitatory input is amplified, and further
#'   inhibition dampened. These forces constrain the activation between a floor
#'   and ceiling value.
#'
#'   Together, these two forces determine the reaction of a node to input. In
#'   particular, from their joint activity a non-linear \emph{activation
#'   function} emerges: The level of activation a node approches over many
#'   interations is an s-shaped function of the input for excitatory links,
#'   concave for positive and convex for negative input. For an inhibitory link,
#'   this relationship is inverted.
#'
#'   Activation initially enters a network through the \emph{source node}, which
#'   provides a constant level of activation. As activation enters the network
#'   and is passed between nodes, the properties sketched above ensure that the
#'   relationships between the concepts represented will increasingly be
#'   satisfied, and after some time, the network reaches a stable state in which
#'   nodes connected by excitatory links will share broadly similar levels of
#'   activation, and those connected by inhibitory links dissimilar states.
#'   Thus, the constraints represented in the network will be increasingly
#'   satisfied (giving the model family its name), and the representation will
#'   become \emph{coherent}.
#'
#'   When a network has converged into this state, \emph{behavioral predictions}
#'   can be derived: The number of iterations that passed during processing is
#'   used as a proxy for decision time, of the nodes representing choice
#'   alternatives, the one with the highest activation is assumed to be the
#'   chosen one, and the difference between the activations of these nodes is
#'   used to predict the confidence with which a decision is made or a course of
#'   action taken.
#'
#' @section Package contents:
#'
#'   This package contains all necessary simulation code to build and run PCS
#'   models. In particular, it contains a full, optimized implementation of the
#'   core model as specified by McClelland and Rumelhart (1981) as well as
#'   Glöckner and Betsch (2008), as well as several variants commonly used in
#'   the literature so that existing findings may be replicated.
#'
#'   \code{\link{PCS_run}} is the central function provided by the package. It
#'   creates, and runs, a model of a PCS network given a connection matrix and
#'   the necessary parameters.
#'
#'   Please see the function-specific documentation for additional information
#'
#' @references PCS
#'
#'   Glöckner, A., & Betsch, T. (2008). Modeling option and strategy choices
#'   with connectionist networks: Towards an integrative model of automatic and
#'   deliberate decision making. Judgment and Decision Making, 3(3), 215–228.
#'
#'   Glöckner, A., Betsch, T., & Schindler, N. (2010). Coherence shifts in
#'   probabilistic inference tasks. Journal of Behavioral Decision Making,
#'   23(5), 439–462. doi:10.1002/bdm.668
#'
#'   Glöckner, A., Hilbig, B. E., & Jekel, M. (2014). What is adaptive about
#'   adaptive decision making? A parallel constraint satisfaction account.
#'   Cognition, 133(3), 641–666. doi:10.1016/j.cognition.2014.08.017
#'
#'   Holyoak, K. J., & Simon, D. (1999). Bidirectional reasoning in decision
#'   making by constraint satisfaction. Journal of Experimental Psychology:
#'   General, 128(1), 3–31.
#'
#'   McClelland, J. L., & Rumelhart, D. E. (1981). An interactive activation
#'   model of context effects in letter perception: I. An account of basic
#'   findings. Psychological Review, 88(5), 375–407.
#'
#'   Rumelhart, D. E., & McClelland, J. L. (1982). An interactive activation
#'   model of context effects in letter perception: II. The contextual
#'   enhancement effect and some tests and extensions of the model.
#'   Psychological Review, 89(1), 60–94.
#'
#'   Simon, D., & Holyoak, K. (2002). Structural dynamics of cognition: From
#'   consistency theories to constraint satisfaction. Personality and Social
#'   Psychology Review, 6(4), 283–294.
#'
#' @docType package
#' @name PCSinR
NULL
#> NULL
