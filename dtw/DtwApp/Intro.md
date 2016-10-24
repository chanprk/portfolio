Stock prices tend to move in groups. By observing many stocks simultaneously, one can identify price movements that are shared among them. This, in turn, makes it easier to separate price moves caused by market-wide news instead of the firm-specific.

In this report, I take a data-driven method to discovery such co-movement. A time series clustering method based on [dynamic time warping distance](https://en.wikipedia.org/wiki/Dynamic_time_warping) is applied to price time series of `FTSE 100` stocks between **1 May** and **7 October** this year. The grouping stage is automated by the tool [dtwclust](https://cran.r-project.org/web/packages/dtwclust/README.html). The number of cluster is set to five to make this report manageble.

After each stocks is grouped into each of the clusters. I manually identify the possible underlying factors behind common price moves, as well as, the possible characteristic of each stock which fit it into the cluster it belongs to.

