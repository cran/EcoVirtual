% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/intEcoVirtual.R
\name{rich}
\alias{rich}
\title{Number of Species}
\usage{
rich(x)
}
\arguments{
\item{x}{a vector with names.}
}
\value{
returns the number of species (species richness).
}
\description{
Count the number of species (species richness) from a vector with a species
list.
}
\details{
This function is used internally in the functions 'simHub1', simHub2', and
'simHub3'.
}
\examples{

lsp <- sample(LETTERS,50,replace=TRUE)
lsp
rich(lsp)

}
\author{
Alexandre Adalardo de Oliveira \email{ecovirtualpackage@gmail.com}
}
\keyword{Functions}
\keyword{Internal}
\keyword{Neutral}
\keyword{Theory}
\keyword{simulation}

