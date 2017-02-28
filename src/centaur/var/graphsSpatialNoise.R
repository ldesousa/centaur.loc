library(gstat)
library(sp)

# Spatially correlated noise example for 4 time-steps
xy <- expand.grid(66660:66805, 20930:21056)
names(xy) <- c('x','y')
g.dummy <- gstat(formula=z~1, locations=~x+y, dummy=T, beta=0, model=vgm(psill=0.025, range=5, model='Exp'), nmax=20)
yy <- predict(g.dummy, newdata=xy, nsim=6)
[using unconditional Gaussian simulation]
gridded(yy) = ~x+y

# Plot first time step 
spplot(obj=yy[1])

# Plot all time steps 
spplot(obj=yy)