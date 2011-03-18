      subroutine starma (ip,iq,ir,np,phi,theta,a,p,v,thetab,xnext,xrow,
     +                   rbar,nrbar,ifault)
c
c   algorithm as 154 appl. statist. (1980) vol.29, no.3
c
c   invoking this subroutine sets the values of v and phi, and obtains
c   the initial values of a and p.
c   this routine is not suitable for use with an ar(1) process.
c   in this case the following instructions should be used for
c   initialisation.
c          v(1)=1.0
c          a(1)=0.0
c          p(1)=1.0/(1.0-phi(1)*phi(1))
c
      dimension phi(ir),theta(ir),a(ir),p(np),v(np),thetab(np),
     +          xnext(np),xrow(np),rbar(nrbar)
c
c   check for failure indication.
c
      ifault=0
      if (ip.lt.0) ifault=1
      if (iq.lt.0) ifault=ifault+2
      if (ip*ip+iq*iq.eq.0) ifault=4
      k=iq+1
      if (k.lt.ip) k=ip
      if (ir.ne.k) ifault=5
      if (np.ne.ir*(ir+1)/2) ifault=6
      if (nrbar.ne.np*(np-1)/2) ifault=7
      if (ir.eq.1) ifault=8
      if (ifault.ne.0) return
c
c   now set a(0),v and phi.
c
      do 10 i=2,ir
      a(i)=0.0
      if (i.gt.ip) phi(i)=0.0
      v(i)=0.0
      if (i.le.iq+1) v(i)=theta(i-1)
   10 continue
      a(1)=0.0
      if (ip.eq.0) phi(1)=0.0
      v(1)=1.0
      ind=ir
      do 20 j=2,ir
      vj=v(j)
      do 20 i=j,ir
      ind=ind+1
      v(ind)=v(i)*vj
   20 continue
c
c   now find p(0).
c
   30 if (ip.eq.0) go to 300
c
c   the set of equations s*vec(p(0))=vec(v) is solved for vec(p(0)).
c   s is generated row by row in the array xnext.
c   the order of elements in p is changed, so as to bring more leading
c   zeros into the rows of s, hence achieving a reduction of computing
c   time.
c
      ir1=ir-1
      irank=0
      ifail=0
      ssqerr=0.0
      do 40 i=1,nrbar
   40 rbar(i)=0.0
      do 50 i=1,np
      p(i)=0.0
      thetab(i)=0.0
      xnext(i)=0.0
   50 continue
      ind=0
      ind1=0
      npr=np-ir
      npr1=npr+1
      indj=npr1
      ind2=npr
      do 110 j=1,ir
      phij=phi(j)
      xnext(indj)=0.0
      indj=indj+1
      indi=npr1+j
      do 110 i=j,ir
      ind=ind+1
      ynext=v(ind)
      phii=phi(i)
      if (j.eq.ir) go to 100
      xnext(indj)=-phii
      if (i.eq.ir) go to 100
      xnext(indi)=xnext(indi)-phij
      ind1=ind1+1
      xnext(ind1)=-1.0
  100 xnext(npr1)=-phii*phij
      ind2=ind2+1
      if (ind2.gt.np) ind2=1
      xnext(ind2)=xnext(ind2)+1.0
      weight=1.0
      call inclu2 (np,nrbar,weight,xnext,xrow,ynext,p,rbar,thetab,ssqerr
     +            ,recres,irank,ifail)
      xnext(ind2)=0.0
      if (i.eq.ir)  go to 110
      xnext(indi)=0.0
      indi=indi+1
      xnext(ind1)=0.0
  110 continue
      call regres (np,nrbar,rbar,thetab,p)
c
c   now re-order p.
c
      ind=npr
      do 200 i=1,ir
      ind=ind+1
      xnext(i)=p(ind)
  200 continue
      ind=np
      ind1=npr
      do 210 i=1,npr
      p(ind)=p(ind1)
      ind=ind-1
      ind1=ind1-1
  210 continue
      do 220 i=1,ir
  220 p(i)=xnext(i)
      return
c
c   p(0) is obtained by backsubstitution for a moving average process.
c
  300 indn=np+1
      ind=np+1
      do 310 i=1,ir
      do 310 j=1,i
      ind=ind-1
      p(ind)=v(ind)
      if (j.eq.1) go to 310
      indn=indn-1
      p(ind)=p(ind)+p(indn)
  310 continue
      return
      end
      subroutine karma (ip,iq,ir,np,phi,theta,a,p,v,
     +                  n,w,resid,sumlog,ssq,iupd,delta,e,nit)
c
c   algorithm as 154.1 appl. statist. (1980) vol.29, no.3
c
c   invoking this subroutine updates a,p,sumlog and ssq by inclusion
c   of data values w(1) to w(n). the corresponding values of resid
c   are also obtained.
c   when ft is less than (1+delta) ,quick recursions are used.
c
      dimension phi(ir),theta(ir),a(ir),p(np),v(np),w(n),resid(n),e(ir)
      ir1=ir-1
      do 10 i=1,ir
   10 e(i)=0.0
      inde=1
c
c   for non-zero values of nit , perform quick recursions.
c
      if (nit.ne.0) go to 600
      do 500 i=1,n
      wnext=w(i)
c
c   prediction.
c
      if (iupd.eq.1.and.i.eq.1) go to 300
c
c   here dt=ft-1.0
c
      dt=0.0
      if (ir.ne.1) dt=p(ir+1)
      if (dt.lt.delta) go to 610
      a1=a(1)
      if (ir.eq.1) go to  110
      do 100 j=1,ir1
  100 a(j)=a(j+1)
  110 a(ir)=0.0
      if (ip.eq.0) go to 200
      do 120 j=1,ip
  120 a(j)=a(j)+phi(j)*a1
  200 ind=0
      indn=ir
      do 210 l=1,ir
      do 210 j=l,ir
      ind=ind+1
      p(ind)=v(ind)
      if (j.eq.ir) go to 210
      indn=indn+1
      p(ind)=p(ind)+p(indn)
  210 continue
c
c   updating.
c
  300 ft=p(1)
      ut=wnext-a(1)
      if (ir.eq.1) go to 410
      ind=ir
      do 400 j=2,ir
      g=p(j)/ft
      a(j)=a(j)+g*ut
      do 400 l=j,ir
      ind=ind+1
      p(ind)=p(ind)-g*p(l)
  400 continue
  410 a(1)=wnext
      do 420 l=1,ir
  420 p(l)=0.0
      resid(i)=ut/sqrt(ft)
      e(inde)=resid(i)
      inde=inde+1
      if (inde.gt.iq) inde=1
      ssq=ssq+ut*ut/ft
      sumlog=sumlog+alog(ft)
  500 continue
      nit=n
      return
c
c   quick recursions
c
  600 i=1
  610 nit=i-1
      do 650 ii=i,n
      et=w(ii)
      indw=ii
      if (ip.eq.0) go to 630
      do 620 j=1,ip
      indw=indw-1
      if (indw.lt.1) go to 630
      et=et-phi(j)*w(indw)
  620 continue
  630 if (iq.eq.0) go to 645
      do 640 j=1,iq
      inde=inde-1
      if (inde.eq.0) inde=iq
      et=et-theta(j)*e(inde)
  640 continue
  645 e(inde)=et
      resid(ii)=et
      ssq=ssq+et*et
      inde=inde+1
      if (inde.gt.iq) inde=1
  650 continue
      return
      end
      subroutine kalfor (m,ip,ir,np,phi,a,p,v,work)
c
c   algorithm as 154.2 appl. statist. (1980) vol.29, no.3
c
c   invoking this subroutine obtains predictions of a and p ,
c   m steps ahead.
c
      dimension phi(ir),a(ir),p(np),v(np),work(ir)
      ir1=ir-1
      do 300 l=1,m
c
c   predict a.
c
      a1=a(1)
      if (ir.eq.1) go to 110
      do 100 i=1,ir1
  100 a(i)=a(i+1)
  110 a(ir)=0.0
      if (ip.eq.0) go to 200
      do 120 j=1,ip
  120 a(j)=a(j)+phi(j)*a1
c
c   predict p.
c
  200 do 210 i=1,ir
  210 work(i)=p(i)
      ind=0
      ind1=ir
      dt=p(1)
      do 220 j=1,ir
      phij=phi(j)
      phijdt=phij*dt
      do 220 i=j,ir
      ind=ind+1
      phii=phi(i)
      p(ind)=v(ind)+phii*phijdt
      if (j.lt.ir) p(ind)=p(ind)+work(j+1)*phii
      if (i.eq.ir) go to 220
      ind1=ind1+1
      p(ind)=p(ind)+work(i+1)*phij+p(ind1)
  220 continue
  300 continue
      return
      end
      subroutine inclu2 (np,nrbar,weight,xnext,xrow,ynext,d,rbar,thetab,
     +                   ssqerr,recres,irank,ifault)
c
c   algorithm as 154.3 appl. statist. (1980) vol.29, no.3
c
c   fortran version of revised version of algorithm as 75.1
c   appl. statist. (1974) vol.23, no. 3.
c   see remark as r17 appl. statist. (1976) vol. 25, no. 3.
c
      dimension xnext(np),xrow(np),d(np),rbar(nrbar),thetab(np)
c
c   invoking this subroutine updates d,rbar,thetab,ssqerr and irank by
c   the inclusion of xnext and ynext with a specified weight. the
c   values of xnext,ynext and weight will be conserved.
c   the corresponding value of recres is calculated.
c
      y=ynext
      wt=weight
      do 10 i=1,np
   10 xrow(i)=xnext(i)
      recres=0.0
      ifault=1
      if (wt.le.0.0) return
      ifault=0
c
      ithisr=0
      do 50 i=1,np
      if (xrow(i).ne.0.0) go to 20
      ithisr=ithisr+np-i
      go to 50
   20 xi=xrow(i)
      di=d(i)
      dpi=di+wt*xi*xi
      d(i)=dpi
      cbar=di/dpi
      sbar=wt*xi/dpi
      wt=cbar*wt
      if (i.eq.np) go to 40
      i1=i+1
      do 30 k=i1,np
      ithisr=ithisr+1
      xk=xrow(k)
      rbthis=rbar(ithisr)
      xrow(k)=xk-xi*rbthis
      rbar(ithisr)=cbar*rbthis+sbar*xk
   30 continue
   40 xk=y
      y=xk-xi*thetab(i)
      thetab(i)=cbar*thetab(i)+sbar*xk
      if (di.eq.0.0) go to 100
   50 continue
      ssqerr=ssqerr+wt*y*y
      recres=y*sqrt(wt)
      return
  100 irank=irank+1
      return
      end
      subroutine regres (np,nrbar,rbar,thetab,beta)
c
c   algorithm as 154.4 appl. statist. (1980) vol.29, no.3
c
c   revised version of algorithm as 75.4 appl. statist. (1974) vol.23 no.3
c   invoking this subroutine obtains beta by backsubstitution
c   in the triangular system rbar and thetab.
c
      dimension rbar(nrbar), thetab (np),beta(np)
      ithisr=nrbar
      im=np
      do 50 i=1,np
      bi=thetab(im)
      if (im.eq.np) go to 30
      i1=i-1
      jm=np
      do 10 j=1,i1
      bi=bi-rbar(ithisr)*beta(jm)
      ithisr=ithisr-1
      jm=jm-1
   10 continue
   30 beta(im)=bi
      im=im-1
   50 continue
      return
      end
