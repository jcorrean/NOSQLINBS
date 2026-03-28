*******************************************************************.
*   Field, A. & Gillett, R. (2009)   "How To Do Meta-Analysis".
*   British Journal of Mathematical and Statistical Psychology.
*******************************************************************.
define Moderator_r  (r = !tokens(1) /n = !tokens(1)  /conmods = !default('') !enclose('(',')') /catmods = !default('') !enclose('(',')') )
dataset name original.
dataset copy meta window=hidden.
dataset activate meta.
compute ru = !r-!r*(1-!r**2)*.5/(!n-3). 
compute zr = .5*ln((1+ru)/(1-ru)).
compute w = !n-3.
compute tcv = idf.t(.975,$casenum).
set mxloops = 10000.
matrix.
get zr / variables = zr  /missing=omit.
get tcv / variables = tcv.
get w / variables = w  /missing=omit.
!if (!conmods !eq !null) !then
compute nconts=0.
!else
get conts / variables = !conmods  /name=contname  /missing=omit.
compute nconts = ncol(conts).
!ifend
!if (!catmods !eq !null) !then
compute ncats=0.
!else
get cats / variables = !catmods  /name=catname  /missing=omit.
compute ncats = ncol(cats).
!ifend
compute nmods = nconts + ncats.
compute pnames=make((nmods+1),1,'Constant').
compute pred={'  .000 =',' 1.000 =',' 2.000 =',' 3.000 =',' 4.000 =',' 5.000 =',' 6.000 =',' 7.000 =',' 8.000 =',' 9.000 =','10.000 =','11.000 =','12.000 ='}.
compute k = nrow(zr).
compute u=make(k,1,1).
compute x=u.
do if (nconts>0).
compute pnames(2:(nconts+1))=t(contname).
compute x={x,conts}.
end if.
compute totcatp=0.
do if (ncats>0).
compute pnames((nconts+2):(nmods+1))=t(catname).
compute catp={0}.
loop modno = 1 to ncats.
compute des=design(cats(:,modno)).
compute m= csum(des).
compute p=ncol(m).
compute catp={catp,(p-1)}.
compute totcatp=totcatp+p-1.
compute ww=w.
compute a=des.
loop i=1 to k .
do if (a(i,p)=1).
loop j=1 to (p-1).
compute a(i,j)=-m(j)/m(p).
end loop.
end if.
end loop.
compute x={x,a(:,1:(p-1))} .
end loop.
compute catp=catp(2:(ncats+1)).
end if.
compute p=ncol(x).
print /title = "**********   META-ANALYSIS OF CORRELATION COEFFICIENTS:  r   **********".
print.
print /title='Note:   The analysis has been conducted on Fisher-transformed correlations.'.
print /title='Note:   Statistics, e.g., b-coefficients, refer to Fisher-transformed correlations.'.
print /title='Note:   The overall mean has been back-transformed into the original r scale.'.   
print.
print.
print /title="**********  FIXED EFFECTS REGRESSION ANALYSIS  **********".
compute sw=t(w)*u.
compute sw2=t(w&**2)*u.
compute swt=t(w&*zr)*u.
compute swt2=t(w&*zr&**2)*u.
compute grandm=msum(swt)/msum(sw).
compute q=msum(swt2)-grandm**2*msum(sw).
compute c=sw-sw2/sw.
compute se = 1/sqrt(msum(sw)).
compute zgrandm=grandm/se.
compute low = grandm - tcv(k-1)*se.
compute upp = grandm + tcv(k-1)*se.
compute vc=inv(t(x)*mdiag(w)*x).
compute bhat=vc*t(x)*mdiag(w)*zr.
compute qtotal=t(zr)*mdiag(w)*zr.
compute qr=t(bhat)*inv(vc)*bhat.
compute qe=qtotal - qr.
compute invgm = (exp(2*grandm)-1)/(exp(2*grandm)+1).
compute invlow =(exp(2*low)-1)/(exp(2*low)+1).
compute invupp =(exp(2*upp)-1)/(exp(2*upp)+1).
print.
print /title='== MODEL WITHOUT PREDICTORS =='.
print {invgm, invlow, invupp, zgrandm, 2*(1 - tcdf(abs({zgrandm}),k-1)), k}/clabels=Mean, Lower, Upper, t, p, n/format='f9.3'/title='OVERALL MEAN:  95% CONFIDENCE BOUNDS,  TEST DIFFERENCE FROM ZERO '.
print.
compute vt=mmax({0,((q-k+1)/c)}).
print {vt, q, (k-1), (1-chicdf(q,(k-1)))}/clabels='Variance', Chi2, df, p /format='f9.3'/title='ESTIMATED EFFECT SIZE VARIANCE  (OVERALL HETEROGENEITY):  Q STATISTIC'.
print.
print /title='== MODEL WITH PREDICTORS =='.
print {t(pred(1:(nmods+1))),pnames} /format='a8'/title='PREDICTOR NUMBERING'.
print /title='CONTINUOUS PREDICTORS:  B-COEFFICIENT, 95% CONFID. BOUNDS, STAND. ERROR, T-TEST  '.
loop i= 1 to (p-totcatp).
compute se = sqrt(vc(i,i)).
compute zbhat=bhat(i)&/se.
compute low = bhat(i) - tcv(k-p-1)*se.
compute upp = bhat(i) + tcv(k-p-1)*se.
print {(i-1), bhat(i), low, upp, se, k-p-1, zbhat, 2*(1 - tcdf(abs({zbhat}),k-p-1))}/clabels=Predictr, 'B-Coeff', Lower, Upper, 'Std Err', df, t, p  /format='f9.3'/title=' '.
end loop.
do if (ncats>0).
print.
print /title='CATEGORICAL PREDICTORS:  CHI-SQUARED TEST'.
compute h=nconts+1.
loop i= 1 to ncats.
compute f=h+1.
compute g=h+catp(i).
compute qcat=t(bhat(f:g))*inv(vc(f:g,f:g))*bhat(f:g).
print {(nconts+i), qcat, catp(i),  (1-chicdf(qcat,catp(i)))}/clabels=Predictr, Chi2, df, p /format='f9.3'/title=' '.
compute h=g.
end loop.
end if.
print.
print {qe, (k-p), (1-chicdf(qe,(k-p)))}/clabels=Chi2, df, p /format='f9.3'/title='RESIDUAL VARIATION:   QE STATISTIC  (GOODNESS OF FIT)'.
print.
print.
print /title="**********  RANDOM EFFECTS REGRESSION ANALYSIS  **********".
compute dw = mdiag(w).
compute tr = trace(dw-dw*x*inv(t(x)*dw*x)*t(x)*dw).
compute ww=1/(1/w+vt).
compute sw=t(ww)*u.
compute swt=t(ww&*zr)*u.
compute swt2=t(ww&*zr&**2)*u.
compute grandm=msum(swt)/msum(sw).
compute se = 1/sqrt(msum(sw)).
compute zgrandm=grandm/se.
compute low = grandm - tcv(k-1)*se.
compute upp = grandm + tcv(k-1)*se.
compute invgm = (exp(2*grandm)-1)/(exp(2*grandm)+1).
compute invlow =(exp(2*low)-1)/(exp(2*low)+1).
compute invupp =(exp(2*upp)-1)/(exp(2*upp)+1).
print.
print /title='== MODEL WITHOUT PREDICTORS =='.
print {invgm, invlow, invupp, zgrandm, 2*(1 - tcdf(abs({zgrandm}),k-1)), k}/clabels=Mean, Lower, Upper, t, p, n/format='f9.3'/title='OVERALL MEAN:  95% CONFIDENCE BOUNDS,  TEST DIFFERENCE FROM ZERO '.
print.
compute vtau=mmax({0,((qe-k+p)/tr)}).
compute ww=1/(1/w+vtau).
compute sw=t(ww)*x(:,1).
compute swt=t(ww&*zr)*x(:,1).
compute swt2=t(ww&*zr&**2)*x(:,1).
compute vc=inv(t(x)*mdiag(ww)*x).
compute bhat=vc*t(x)*mdiag(ww)*zr.
compute qtotal=t(zr)*mdiag(ww)*zr.
compute qr=t(bhat)*inv(vc)*bhat.
compute qe=qtotal - qr.
print.
print /title='== MODEL WITH PREDICTORS =='.
print {t(pred(1:(nmods+1))),pnames} /format='a8'/title='PREDICTOR NUMBERING'.
print /title='CONTINUOUS PREDICTORS:  B-COEFFICIENT, 95% CONFID. BOUNDS, STAND. ERROR, T-TEST  '.
loop i= 1 to (p-totcatp).
compute se = sqrt(vc(i,i)).
compute zbhat=bhat(i)&/se.
compute low = bhat(i) - tcv(k-p-1)*se.
compute upp = bhat(i) + tcv(k-p-1)*se.
print {(i-1), bhat(i), low, upp, se, k-p-1, zbhat, 2*(1 - tcdf(abs({zbhat}),k-p-1))}/clabels=Predictr, 'B-Coeff', Lower, Upper, 'Std Err', df, t, p  /format='f9.3'/title=' '.
end loop.
do if (ncats>0).
print.
print /title='CATEGORICAL PREDICTORS:  CHI-SQUARED TEST'.
compute h=nconts+1.
loop i= 1 to ncats.
compute f=h+1.
compute g=h+catp(i).
compute qcat=t(bhat(f:g))*inv(vc(f:g,f:g))*bhat(f:g).
print {(nconts+i), qcat, catp(i),  (1-chicdf(qcat,catp(i)))}/clabels=Predictr, Chi2, df, p /format='f9.3'/title=' '.
compute h=g.
end loop.
end if.
print.
print {qe, (k-p), (1-chicdf(qe,(k-p)))}/clabels=Chi2, df, p /format='f9.3'/title='RESIDUAL VARIATION:   QE STATISTIC  (GOODNESS OF FIT)'.
print.
print.
end matrix.
dataset activate original window=asis.
dataset close meta.
!enddefine.