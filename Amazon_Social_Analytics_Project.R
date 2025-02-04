title: Social Network and Analytics Project

Delete products that are not books from "products" and "copurchase" files. 
```{r}
getwd()
products <- read.csv("products.csv")
copurchase <- read.csv("copurchase.csv")
products1 <- products[products$group == "Book", ]
Book <- subset(products1, salesrank <= 150000 & salesrank != -1)
Book$downloads <- NULL
copurchase1 <- subset(copurchase, Source %in% Book$id & Target %in% Book$id)
```

Create a variable named in-degree, to show how many "Source" products people who buy "Target" products buy; 
i.e. how many edges are to the focal product in "co-purchase" network.
```{r}
install.packages("igraph")
library(igraph)
network <- graph.data.frame(copurchase1, directed = T)
indegree <- degree(network, mode = 'in')
```
Create a variable named out-degree, to show how many "Target" products people who buy "Source" product also buy;
i.e., how many edges are from the focal product in "co-purchase" network.
```{r}
outdegree <- degree(network, mode = 'out')
```
Pick up one of the products (in case there are multiple) with highest degree (in-degree + out-degree), 
and find its subcomponent, i.e., all the products that are connected to this focal product.
```{r}
alldegree <- degree(network, mode = 'total')
max(alldegree)
which(alldegree==53)
sub_all <- subcomponent(network, "33",'all')
```
Visualize the subcomponent using iGraph, trying out different colors, node and edge sizes and layouts, so that 
the result is most appealing. Find the diameter, and color the nodes along the diameter. Provide your insights from the visualizations.
```{r}
newgraph<-subgraph(network,sub_all)
diameter(newgraph, directed=F, weights=NA)
diam <- get_diameter(newgraph, directed=T)
as.vector(diam)
V(newgraph)$color<-"skyblue"
V(newgraph)$size<-2
V(newgraph)[diam]$color<-"darkblue"
V(newgraph)[diam]$size<-5
par(mar=c(.1,.1,.1,.1))
plot.igraph(newgraph,
            vertex.label=NA,
            edge.arrow.size=0.00001,
            layout=layout.kamada.kawai)
```
The graph demonstrates 904 vertices, 904 book ids which are connected with each other.  Some of them have stronger connections like clusters in the middle with short edges, some of them have weaker ties which are nodes on the edges of the plot. Diameter shows the longest geodesic distance between two vertices. We have defined node attributes for the diameter that is why it is plotted with larger nodes of dark blue color. In our visualization, the distance is 41 and there are 10 vertices in the diameter (37895 27936 21584 10889 11080 14111 4429  2501  3588  6676) which have the longest distance between them.

Compute various statistics about this network (i.e., subcomponent), including degree distribution, density, and 
centrality (degree centrality, closeness centrality and between centrality), hub/authority scores, etc. Interpret your results.degree distribution (in-degree, out-degree and both).
```{r}
deg1 <- degree(newgraph, mode = "all")
deg.dist.all <- degree_distribution(newgraph, cumulative=T, mode="all")
centr_degree(newgraph,mode="all",normalized=T)
plot( x=0:max(deg1), y=1-deg.dist.all, pch=19, cex=1.2, col="orange", 
      xlab="Degree", ylab="Cumulative Frequency")

deg2 <- degree(newgraph, mode = "in")
deg.dist.in <- degree_distribution(newgraph, cumulative=T, mode="in")
centr_degree(newgraph,mode="in",normalized=T)
plot( x=0:max(deg2), y=1-deg.dist.in, pch=19, cex=1.2, col="blue",      
      xlab="Degree", ylab="Cumulative Frequency")

deg3 <- degree(newgraph, mode = "out")
deg.dist.out <- degree_distribution(newgraph, cumulative=T, mode="out")
centr_degree(newgraph,mode="out",normalized=T)
plot( x=0:max(deg3), y=1-deg.dist.out, pch=19, cex=1.2, col="red", 
      xlab="Degree", ylab="Cumulative Frequency")
```
The degree of a node refers to the number of ties associated with a node. Deg1 measures all the ties going in and out. In our case, deg1 gives an output of books ids and their corresponding total number of links going to and from the focal product in the network.Degree distribution deg.dist.all  shows the cumulative frequency of nodes with degree Deg1. The centralization function centr_degree returned res - vertex centrality, centralization of 0.02794058, and theoretical_max  1630818 - maximum centralization score for the newgraph. 
Deg2 measures all the ties going in. In our case, deg2 gives an output of books ids and their corresponding total number of links going to the focal product in the network.Degree distribution deg.dist.in shows the cumulative frequency of nodes with degree Deg2. The centralization function centr_degree returned res - vertex centrality, centralization of 0.05725629, and theoretical_max  816312- maximum centralization score for the newgraph.Deg3 measures all the ties going out. In our case, deg3 gives an output of books ids and their corresponding total number of links going from the focal product.Degree distribution deg.dist.out  shows the cumulative frequency of nodes with degree Deg3. The centralization function centr_degree returned res - vertex centrality, centralization of 0.002992728,and theoretical_max  816312- maximum centralization score for the newgraph.We can observe that maximum centralization score for indegree and outdegree ties is the same 816312.
```{r}
edge_density(newgraph, loops=F)
```
Density is the proportion of present edges from all possible ties. For our network, density is 0.001436951.
```{r}
closeness<-closeness(newgraph, mode="all", weights=NA)
centr_clo(newgraph,mode="all",normalized=T)
```
Closeness refers to how connected a node is to its neighbors. It is inverse of the node's average geodesic distance to others. The higher values are the less centrality is in the network. Besides that, centralization function centr_clo returned centralization score of 0.1074443 and theoretical max of 451.2499 for the graph.
```{r}
betwenness<-betweenness(newgraph, directed=T, weights=NA)
edge_betweenness(newgraph,directed = T, weights=NA)
centr_betw(newgraph,directed = T,normalized=T)
```
Betweenness is the number of shortest paths between two nodes that go through each node of interest. Betweenness
calculates vertex betweenness, edge_betweenness calculates edge betweenness. Vertix 2501 has a high betweenness 298 which indicates that it has a considerable influence within a network due to its control over information passing between others. Its removal from the network may disrupt communications between other vertices because it lies on the largest number of paths. Its centralization function also returns centralization score of 0.0003616307 and theoretical max of 735498918.
```{r}
hub<-hub.score(newgraph)$vector
auth<-authority.score(newgraph)$vector
plot(newgraph,
vertex.size=hub*5,
main = 'Hubs',
vertex.color.hub = "skyblue",
vertex.label=NA,
edge.arrow.size=0.00001,
layout = layout.kamada.kawai)
plot(newgraph,
vertex.size=auth*10,
main = 'Authorities',
vertex.color.auth = "skyblue",
vertex.label=NA,
edge.arrow.size=0.00001,
layout = layout.kamada.kawai)
```
Hubs refer to max outgoing links whereas Authorities refer to max incoming links. 

Create a group of variables containing the information of neighbors that "point to" focal products. The variables include:
a.	Neighbors' mean rating (nghb_mn_rating), 
b.	Neighbors' mean salesrank (nghb_mn_salesrank), 
c.	Neighbors' mean number of reviews (nghb_mn_review_cnt)
```{r}
sub_all1 <-as_ids(sub_all)
Book$id <- as.character(Book$id)
filtered <- Book[Book$id %in% sub_all1,]
copurchase$Target <- as.character(copurchase$Target)

mean_values <- inner_join(copurchase, filtered, by = c("Target"="id")) %>%
  group_by(Target) %>%
  summarise(nghb_mn_rating = mean(rating),
            nghb_mn_salesrank = mean(salesrank),
            nghb_mn_review_cnt = mean(review_cnt))
```
Include the variables (taking logs where necessary) created in Parts 2-6 above into the "products" information and fit a Poisson regression to predict salesrank of all the books in this subcomponent using products' own information and their neighbor's information. Provide an interpretation of your results. 
```{r}
in_degree1 <- as.data.frame(deg2)
in_degree1 <- cbind(id = rownames(in_degree1), in_degree1)
out_degree1 <- as.data.frame(deg3)
out_degree1 <- cbind(id = rownames(out_degree1), out_degree1)

closeness1 <- as.data.frame(closeness)
closeness1 <- cbind(id = rownames(closeness1), closeness1)
betweenness1 <- as.data.frame(betweenness)
betweenness1 <- cbind(id = rownames(betweenness1), betweenness1)

hub_score2 <- as.data.frame(hub)
hub_score2 <- cbind(id = rownames(hub_score2), hub_score2)
authority_score2 <- as.data.frame(auth)
authority_score2 <- cbind(id = rownames(authority_score2), authority_score2)

newdf1 <- sqldf("SELECT hub_score2.id,hub, betweenness, auth, closeness, deg2, deg3 
                      FROM hub_score2, betweenness1, authority_score2, closeness1, in_degree1, out_degree1
                      WHERE hub_score2.id = betweenness1.id 
                      and hub_score2.id = authority_score2.id
                      and hub_score2.id = closeness1.id
                      and hub_score2.id = in_degree1.id
                      and hub_score2.id = out_degree1.id")


newdf2 <- sqldf("SELECT Book.id, Book.review_cnt, Book.rating, hub, betweenness, auth, closeness, 
                          deg2, deg3, Book.salesrank, nghb_mn_rating,nghb_mn_review_cnt,nghb_mn_salesrank 
                FROM Book, newdf1,mean_values 
                WHERE newdf1.id = Book.id
                and Book.id=mean_values.Target")

summary(salesrank_prediction<- glm(salesrank ~ review_cnt + rating + hub + betweenness + 
                                     auth + closeness + deg2 + deg3 + nghb_mn_rating + nghb_mn_review_cnt + nghb_mn_salesrank, family="poisson", data=newdf2))
```
