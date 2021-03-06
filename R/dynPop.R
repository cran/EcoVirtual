################################################
### Ecovirtual -  Population Dynamics Models ###
################################################
##' Population Dynamic Models
##' 
##' Functions to simulate population dynamic models.
##' 
##' popExp simulates discrete and continuous exponential population growth.
##' 
##' estEnv simulates a geometric population growth with environmental
##' stochasticity.
##' 
##' BDM simulates simple stochastic birth death and immigration dynamics of a
##' population (Renshaw 1991). simpleBD another algorithm for simple birth dead
##' dynamics. This is usually more efficient than BDM but not implemented
##' migration.
##' 
##' estDem creates a graphic output based on BDM simulations.
##' 
##' Stochastic models uses lambda values taken from a normal distribution with
##' mean lambda and variance varr.
##' 
##' popLog simulates a logistic growth for continuous and discrete models.
##' 
##' popStr simulates a structured population dynamics, with Lefkovitch
##' matrices.
##' 
##' In popStr the number of patches in the simulated scene is defined by rw*cl.
##' 
##' logDiscr simulates a discrete logistic growth model.
##' 
##' bifAttr creates a bifurcation graphic for logistic discrete models.
##'
##' @name dynPop
##' @aliases popExp estEnv BDM simpleBD estDem popLog popStr logDiscr dynPop
##' bifAttr
##' @param N0 number of individuals at start time.
##' @param lamb finite rate of population growth.
##' @param tmax maximum simulation time.
##' @param nmax maximum population size.
##' @param intt interval time size.
##' @param varr variance.
##' @param npop number of simulated populations.
##' @param ext extinction.
##' @param b birth rate.
##' @param d death rate.
##' @param migr migration. logical.
##' @param nsim number of simulated populations.
##' @param cycles number of cycles in simulation.
##' @param r intrinsic growth rate.
##' @param K carrying capacity.
##' @param p.sj probability of seed survival.
##' @param p.jj probability of juvenile survival.
##' @param p.ja probability of transition from juvenile to adult phase.
##' @param p.aa probability of adult survival.
##' @param fec mean number of propagules per adult each cycle.
##' @param ns number of seeds at initial time.
##' @param nj number of juveniles at initial time.
##' @param na number of adults at initial time.
##' @param rw number of rows for the simulated scene.
##' @param cl number of columns for the simulated scene.
##' @param rd discrete growth rate.
##' @param nrd number of discrete population growth rate to simulate.
##' @param maxrd maximum discrete population growth rate.
##' @param minrd minimum discrete population growth rate.
##' @param barpr show progress bar.
##' @param type type of stochastic algorithm.
##' @return The functions return graphics with the simulation results, and a
##' matrix with the population size for deterministic and stochastic models.
##' @author Alexandre Adalardo de Oliveira and Paulo Inacio Prado
##' \email{ecovirtualpackage@@gmail.com}
##' @seealso \code{\link{metaComp}}, \url{http://ecovirtual.ib.usp.br}
##' @references Gotelli, N.J. 2008. A primer of Ecology. 4th ed. Sinauer
##' Associates, 291pp. Renshaw, E. 1991. Modelling biological populations in
##' space and time Cambridge University Press. Stevens, M.H.H. 2009. A primer
##' in ecology with R. New York, Springer.
##' @keywords population dynamics simulation
##' @importFrom stats rexp rlnorm sd time
##' @importFrom utils stack
##' @examples
##' 
##' \dontrun{
##' popStr(p.sj=0.4, p.jj=0.6, p.ja=0.2, p.aa=0.9, fec=0.8, ns=100,nj=40,na=20, rw=30, cl=30, tmax=20)
##' }
##'
########################################################
### Exponential growth - discrete and continuos growth ##
#########################################################
popExp <- function(N0,lamb,tmax, intt= 1) 
{
    ## logical tests for initial conditions
                                        #   N0 <- round(as.numeric(tclvalue(noVar)))
    if (is.na(N0) || N0 <= 0) 
        {
            stop("Number of individuals at the simulation start must be a positive integer")
                                        #            return()
        }
                                        #       tmax <- round(as.numeric(tclvalue(tmaxVar)))
    if (is.na(tmax) || tmax <= 0) 
        {
            stop("Number of simulations must be a positive integer")
                                        #            return()
        }
##########################################
                                        #st<-0:tmax
    ntseq<-seq(0,tmax,by=intt) 
    resulta <- matrix(NA,nrow=length(ntseq), ncol=3)
    nc<-length(ntseq) -1
    rexp0=log(lamb)
    radj=rexp0*intt
    ladj=exp(radj)
    resulta[,1]<-ntseq
    resulta[,2]<-N0*exp(radj*(0:nc))
    resulta[,3]<-N0*ladj^(0:nc)
    ntmax = N0*lamb^tmax
    if(ntmax==Inf)
    {
        stop("The population reached a extreme large number of individuals. This is a typical behavior of exponential growth with large rates or enough time. Use smaller numbers!!")
    }
    if(N0 <= ntmax)
        {
            ymax<-ntmax
            ymin<-N0
        }else
            {
                ymax<-N0
                ymin<-ntmax
            }
    plot(seq(0,tmax, len=10), seq(ymin,ymax,len=10), type="n", main="Discrete and Continuous Exponential Growth", sub= expression(paste(lambda[adj],"=          ", r[adj], "=          ")), xlab="Time", ylab="Population Size (N)", cex.axis=1.3, cex.lab=1.3, xlim=c(0,tmax), ylim=c(ymin, ymax), bty="n")
    title(sub=paste("        ", round(ladj,3),"            ",round(radj,3) ),cex.sub=0.7)
    ##segments(x0=resulta[- dim(resulta)[1],1], y0=resulta[- dim(resulta)[1],3], x1=resulta[- 1,1], y1=resulta[- dim(resulta)[1],3], lty=2, col="blue")
    ##segments(x0=resulta[- 1,1], y0=resulta[- dim(resulta)[1],3], x1=resulta[- 1,1], y1=resulta[- 1,3], lty=2, col="blue")
    seqt=seq(0,tmax,len=1000)
    radj02<-rexp0*tmax/1000
    points(seqt, N0*exp(rexp0*seqt), type="l", lwd=2)
    points(resulta[,1], resulta[,3],pch=16, col="blue")
    invisible(resulta)
}
 #popExp(N0=10,lamb=1.1,tmax=10, intt= 0.9) 
########################################################
### Geometric growth with Environmental Stochasticity ##
#######################################################
##' @rdname dynPop
estEnv <- function(N0, lamb, tmax, varr, npop= 1, ext=FALSE) 
{
    ## logical tests for initial conditions
                                        #   N0 <- round(as.numeric(tclvalue(noVar)))
    if (N0* lamb^tmax == Inf) 
        {
            stop("The population reach a very large number of individuos. Use smaller values of tmax and or lambda")
                                        #            return()
        }
    if (is.na(N0) || N0 <= 0) 
        {
            stop("Number of individuals at the simulation start must be a positive integer")
                                        #            return()
        }
                                        #       tmax <- round(as.numeric(tclvalue(tmaxVar)))
    if (is.na(tmax) || tmax <= 0) 
        {
            stop("Number of simulations must be a positive integer")
                                        #            return()
        }
                                        #        varr <- as.numeric(tclvalue(varrVar))
    if (varr < 0)
        {
            stop(message = "r Variance must be zero (no stochatiscity) or a positive value")
                                        #            return()
        }
###############################################################################
    resulta <- matrix(NA,nrow=tmax, ncol=npop+2)
    resulta[,1] <- seq(0,tmax-1)
    resulta[1,2:(npop+2)] <- N0
    varlog <- log(varr/lamb + 1)
    meanlog <- log(lamb)-varlog/2
    for (t in 2:tmax) 
	{
            resulta[t,2] <- N0*lamb^(t-1)
                        lambe <- rlnorm(npop,meanlog,sqrt(varlog)) 
            resulta[t,3:(npop+2)] <- resulta[t-1,3:(npop+2)]*lambe 
            if (sum(resulta[t,3:(npop+2)])>1 & ext==TRUE) 
		{
                    resulta[t,(3:(npop+2))][resulta[t,(3:(npop+2))]<1] = 0
		}
	}
                                        #dev.new()
                                        #matplot(resulta[,1],resulta[,-c(1,2)], )
    cores=rainbow(npop)
    extN<-sum(resulta[tmax,-c(1,2)]<=0)
    matplot(resulta[,1],resulta[,-c(1,2)],type="l", lty=2, col=cores,
            main="Discrete Population Growth",xlab="Time(t)", cex=0.8, ylab="Population size (N)",
            ylim=c(0,max(resulta[,2:(npop+2)])),
            sub=paste("lambda = ", lamb, "; variance = ", varr, "; extinctions = ", extN, "/", npop),lwd=1.5, bty="n", cex.sub=0.8)
    lines(resulta[,1],resulta[,2], lwd=2)
    legend("topleft",c("deterministic","environment stochastic"),lty=c(1,2), col=c(1,3), bty="n")
                                        #text(x=2, y= resulta[round(tmax*0.8),2], paste("extinctions = ", extN, "/", npop), cex=0.7)
                                        #text(x=tmax*0.6, y= resulta[(tmax/2),2], paste("var=", varr), col="blue")
    invisible(resulta)
}
#estEnv(N0 =  10 , lamb =  1.05 , varr =  0.02 , tmax =  100 , npop =  20 , ext = FALSE )
############################################################
### Simple Stochastic birth death and immigration dynamics ##
## function to run one populations, Gillespie algorithm ####
##########################################################
##' @rdname dynPop
BDM <- function(tmax, nmax=10000, b, d, migr=0, N0, barpr=FALSE)
{
    if(any(c(b,d,migr)<0))stop("b, d, and migr should not be negative")
    if(barpr)
        {
            pb = tkProgressBar(title = "Simulation Progress", max = tmax)
        }
    N <- N0
    tempo <- ctime <- 0
    while(ctime<=tmax & N[length(N)]< nmax)
        {
            if(migr==0&N[length(N)]==0) break
            else
                {
                    ctime <- ctime+rexp(1 , rate=b*N[length(N)] + d*N[length(N)] + migr )
                    tempo <- c(tempo,ctime)
                    N <- c( N,N[length(N)] + sample(c(1,-1), 1, prob=c(b*N[length(N)]+migr,d*N[length(N)])))
                    if(barpr)
                        {
                            setTkProgressBar(pb, value = ctime, label = paste("Time: ",round(ctime[length(ctime)],1), " . Total time: ", tmax, sep=""))
                        }
          }
        }
    if(N[length(N)]>=0&ctime>tmax)
        {
            tempo[length(tempo)] <- tmax
            N[length(N)] <- N[length(N)-1]
        }
    if(barpr)
        {
            close(pb)
        }
    invisible(data.frame(time=tempo, Nt=N))
}
#############################################################
### Just Another Gillespie algorithm for simple birth death #
### without migration, but more efficient 
##########################################################
##' @rdname dynPop
simpleBD = function(tmax=10, nmax =10000 , b=0.2, d=0.2, N0=10, cycles=1000, barpr=FALSE)
    { 
        if(barpr)
            {
                pb = tkProgressBar(title = "Simulation Progress", max = tmax)
            }
ctime=0
nind=N0
while(ctime[length(ctime)]<tmax & (nind[length(nind)]>0 & nind[length(nind)] < nmax))
{
### event sequence (bird or dead)
ybd = runif(cycles,0,1)
bd<-rep(-1,cycles)
bd[ybd <= b/(b+d)] <- 1
cbd <- cumsum(c(nind[length(nind)], bd))
######## time sequence
ytime <-runif(cycles,0,1)
stime <- -(log(ytime))/(cbd[-cycles]*(b+d))
ct <- cumsum(c(ctime[length(ctime)],stime))
ctime <- c(ctime, ct[-1])
nind <-c(nind,cbd[-1])
if(barpr)
          {
              setTkProgressBar(pb, value = ct[length(ct)], label = paste("Simulation time: ", round(ct[length(ct)],1), " ;  maximum time: ", tmax, sep=""))
          }
#### 0 for population < 0 ####
zeros <- nind==0
if(sum(zeros) > 0)
    {
        first0 <- min(which(zeros))
        seq0 <- ((first0+1):(length(nind)))
        nind[seq0]<-0
        ctime[is.infinite(ctime)] <- NA
    }

}
if(barpr)
    {
        close(pb)
    }
invisible(data.frame(time=ctime, Nt=nind))
}
###############################################################
## function for n runs of stochastic birth death immigration ###
###############################################################
##' @rdname dynPop
estDem = function(N0=10, tmax=10, nmax=10000, b=0.2, d=0.2, migr=0, nsim=20, cycles=1000, type= c("simpleBD", "BDM"), barpr= FALSE)
{
    type = match.arg(type)
    if(type=="simpleBD" & migr==0 )
        {
            results <- replicate(nsim, simpleBD(tmax=tmax, b=b, d=d, cycles=cycles, N0=N0, nmax=nmax, barpr=barpr), simplify=FALSE )
        }else{
            results <- replicate(nsim, BDM(tmax=tmax, b=b, d=d, N0=N0, nmax=nmax, barpr=barpr), simplify=FALSE )
        }
    n.ext <- sum(sapply(results,function(x){min(x$Nt[x$time<=tmax], na.rm=TRUE)})==0, na.rm=TRUE)
    tseq=seq(0,tmax, len=1000)
    cores <- rainbow(nsim)
    ymax<-max(sapply(results,function(x)max(x$Nt)))
    plot(results[[1]], type="l",
         main="Stochastic Birth, Death and Immigration",
         xlab= "Time",
         ylab="Population Size",
         cex.lab=1.2,
         cex.main=1.2,
         cex.axis=1.2,
         sub= paste("birth=",b, " death =",d, " migration=",migr),
         bty="n",
         ylim=c(0,ymax),
         xlim=c(0,tmax),
         col=cores[1]
         )
    for(i in 2:length(results)){
        lines(results[[i]],col=cores[i])
    }
    Nt=N0*exp((b-d)*tseq)
    lines(tseq, Nt, lwd=2)
    if(migr==0)
        {
        if(b>d & all(sapply(results, function(x)any(x[,2]==N0*2))))
            {
            d.time <- sapply(results,function(x)min(x[x[,2]==N0*2,1],na.rm=TRUE))
            # m nao declarado, supondo n.ext (A.C. 13.ago.14)
            #if(m>0) texto <-c(paste("extinctions =", n.ext, "/", nsim),
            #texto <-c(paste("extinctions =", n.ext, "/", nsim), paste("Doubling time: mean=",round(mean(d.time),3),"std dev=",round(sd(d.time),3)))
            legend("topright",legend=paste("Doubling time: mean=",round(mean(d.time),3),"std dev=",round(sd(d.time),3)),bty="n")
        }
        if(b<d & all(sapply(results, function(x)any(x[,2]<=N0/2)))){
            h.time <- sapply(results,function(x)min(x[x[,2]<=N0/2,1], na.rm=TRUE))
            legend("topright",
                   legend= paste("Halving time: mean= ",round(mean(h.time, na.rm=TRUE),3)," ,std dev= ",round(sd(h.time, na.rm=TRUE),3),sep=""), bty="n")
        }
    }
    legend(0, ymax*0.9,legend=c(paste("extinctions =", n.ext, "/", nsim)),bty="n")
    invisible(results)
}
#res<-estDem(tmax=100, b=0.5, d=0.6, N0=10, nsim=100, cycles=1000, type="simpleBD", nmax=10000)
########################
## Logistical Growth ###
########################
##' @rdname dynPop
popLog=function(N0, tmax, r, K, ext=FALSE)
{
resulta=matrix(NA, nrow=tmax+1,ncol=3)
colnames(resulta)=c("time", "Continuous Model ", "Discrete Model")
resulta[,1]=0:tmax
resulta[1,3]=N0
#####################
	if (is.na(N0) || N0 <= 0) 
        {
        stop(message = "Number of individuals at the simulation start must be a positive integer")
        }
	if (is.na(tmax) || tmax <= 0) 
        {
            stop("Number of simulations must be a positive integer")
       }
	if (is.na(K) || K <= 0)
        {
            stop("Carrying Capacity (K) must be a positive integer")
        }
######### Ajuste do rdiscreto ############
#lamb=exp(r)
#rd=lamb-1
resulta[,2]<-K/(1+((K-N0)/N0)*exp(-r*(0:tmax)))
##########################################
	for(t in 2:(tmax+1))
	{
	#ifelse(nCont<0,resulta[t,2]<-0, resulta[t,2]<-nCont)
	lastN=resulta[t-1,3]
	nDisc<-lastN+r*lastN*(1-lastN/K)
	resulta[t,3]<-nDisc
		if(ext==TRUE & nDisc<0)
		{
		resulta[t,3]<-0
		}
	}
rangN<-range(resulta[,c(2,3)], na.rm=TRUE)
if(rangN[1]==-Inf){rangN[1]=-10}
if(rangN[2]==Inf){rangN[2]=K*1.2}
plot(resulta[,1], seq(floor(rangN[1]), ceiling(max(rangN[2],K)), len=dim(resulta)[1]), type="n", xlab="Time (t)", main="Logistic Population Growth", ylab="Population size (N)",cex.lab=1.3, cex.axis=1.3, cex.main=1.5, ylim=c(rangN[1], rangN[2]+5), bty="n")
polygon(c(-10,-10, tmax*1.2, tmax*1.2), c(-40,0,0,-40), col="gray80")
###########################
### continuous logistical #
###########################
seqt=seq(0,tmax,len=1000)
#radj0<-r*tmax/1000
seqN<-K/(1+((K-N0)/N0)*exp(-r*(seqt)))
points(seqt, seqN, type="l", lwd=2)
lines(resulta[,1],resulta[,3], col="red", lwd=2, lty=4)	
legend("bottomright", colnames(resulta)[2:3],lty=c(1,4),col=c(1,2),bty="n", lwd=2)
abline(h=K, lty=3, col="blue", lwd=2)
abline(h=0)
text(x=0.2, y=K+1, "Carrying capacity", col="blue",adj=c(0,0), cex=0.7)
#text(x=tmax*0.4, y= resulta[(tmax/2),2], paste("r=", r),pos=3)
title(sub=paste("rd = r = ", round(r,3)),cex.sub=0.9)
invisible(resulta)
}
#popLog(N0=10, r=0.05, K=80, tmax=100, ext=FALSE)
################################################
## Populational Model for structured populations
################################################
##' @rdname dynPop
popStr=function(tmax, p.sj, p.jj, p.ja, p.aa, fec, ns, nj, na, rw, cl)
{
dev.new()
ncel=rw*cl
arena=matrix(0,nrow=rw,ncol=cl)
xy.sem=list()
pais=array(0,dim=c(rw, cl, tmax))
tab.fr=matrix(NA,ncol=4, nrow=tmax)
n0=rep(c(0,2,3), c((ncel-nj-na),nj, na))
arena[1:ncel]<-sample(n0)
image(0:rw, 0:cl, arena, main="Structured Population Dynamics", col=c("white", "green", "darkgreen") , breaks=c(-0.1,1.9,2.9,3.9), xlab="", ylab="")
grid(rw,cl)
xsem=sample(seq(0,cl,0.1), ns, replace=TRUE)
ysem=sample(seq(0,rw,0.1), ns, replace=TRUE)
ind.sem=floor(ysem)*cl + ceiling(xsem)
points(xsem,ysem, col="red", pch=16)
xy.sem[[1]]=cbind(x=xsem,y=ysem)
t.fr=table(arena)
tab.fr[1,as.numeric(names(t.fr))+1]<-t.fr[]
tab.fr[1,2]<-ns
pais[,,1]<-arena
	for (tc in 2:tmax)
	{
	j.vf=pais[,,(tc-1)]==2
		if(sum(j.vf)>0)
		{
		jovem=which(j.vf)
		pais[,,tc][jovem]<-sample(c(0,2,3),length(jovem),replace=TRUE, prob=c((1-(p.jj+p.ja)),p.jj,p.ja))
		}
	a.vf=pais[,,(tc-1)]==3
		if(sum(a.vf)>0)
		{
		adulto=which(a.vf)
		pais[,,tc][adulto]<-sample(c(0,3),length(adulto),replace=TRUE, prob=c((1-p.aa),p.aa))
		}
	n.fec=round(fec*sum(a.vf))
	vazio=which(pais[,,tc]==0)
	sv=vazio%in% ind.sem
		if(sum(sv)>0)
		{
		sem.vazio=vazio[sv]
		pais[,,tc][sem.vazio]<-sample(c(0,2),sum(sv),replace=TRUE, prob=c((1-p.sj),p.sj))
		}
	if(sum(pais[,,tc])==0 & n.fec==0)
	{
	image(0:rw,0:cl, matrix(0,nrow=rw,ncol=cl), col="white", xlab="", ylab="", add=TRUE)
	grid(rw,cl)
	text(rw/2, cl/2, "EXTINCTION", col="red", cex=4)
	break
	}
	image(0:rw,0:cl, matrix(0,nrow=rw,ncol=cl), col="white", xlab="", ylab="", add=TRUE)
	image(0:rw, 0:cl, pais[,,tc], col=c("white", "green", "darkgreen") ,breaks=c(0,1,2,3), xlab="", ylab="",  add=TRUE, sub=paste("simulation no. =",tc ))
	grid(rw,cl)
	xsem=sample(seq(0,cl,0.1), n.fec, replace=TRUE)
	ysem=sample(seq(0,rw,0.1), n.fec, replace=TRUE)
	xy.sem[[2]]=cbind(x=xsem,y=ysem)
	ind.sem=floor(ysem)*cl + ceiling(xsem)
	points(xsem,ysem, col="red", pch=16)
	Sys.sleep(.1)
	t.fr=table(pais[,,tc])
	tab.fr[tc,as.numeric(names(t.fr))+1]<-t.fr[]
	tab.fr[tc,2]<-n.fec
	}
tab.rel=tab.fr/apply(tab.fr,1,sum)
names(tab.rel)<-c("Empty", "Seed", "Juvenile", "Adult")
dev.new()
matplot(tab.rel, type="l",col=c("gray", "red", "green", "darkgreen"),lwd=2,main= "Stage Frequency", ylab="Frequency", xlab="Time (t)")
legend("topright",legend=c("Empty", "Seed", "Juvenile", "Adult") ,lty=1:4, col=c("gray", "red", "green", "darkgreen"), bty="n", cex=0.8 )
invisible(list(simula=pais, xy=xy.sem))
}
#popStr(p.sj=0.05, p.jj=0.99, p.ja=0, p.aa=1, fec=1.2, ns=100,nj=150,na=50, rw=20, cl=20, tmax=100)
#popStr(0.1,0.4,0.3,0.9,1.2,100,80,20, 20,20,100)
###############################################################
#### Bifurcation and atractors - Discrete Logistic Growth 
############################################################### 
##' @rdname dynPop
logDiscr<-function(N0, tmax, rd, K)
  {
  Nt=rep(NA,tmax+1)
  Nt[1]<-N0
    for(t in 2: (tmax+1))
    {
    Nt[t]=Nt[t-1] + (rd * Nt[t-1]* (1-(Nt[t-1]/K))) 
    }
return(Nt)
}
#####################################
#  Bifurcation graphic for logistic
#####################################
##' @rdname dynPop
bifAttr=function(N0, K, tmax, nrd, maxrd=3, minrd=1)
{
rd.s=seq(minrd,maxrd,length=nrd)
r1=sapply(rd.s, function(x){logDiscr(N0=N0, rd=x, K=K,tmax=tmax)})
r2=stack(as.data.frame(r1))
names(r2)=c("N", "old.col")
r2$rd=rep(rd.s,each=tmax+1)
r2$time=rep(0:tmax, nrd)
res.bif=subset(r2, time>0.5*tmax)
plot(N~rd, data=res.bif, pch=".", cex=2, ylab="Population size (N) attractors", xlab="Discrete population growth rate (rd)", cex.axis=1.2, main="Discrete Logistic Bifurcation")
invisible(res.bif)
}
##bifAttr(N0=50,K=100,tmax=200,nrd=500, minrd=1.9, maxrd=3)
