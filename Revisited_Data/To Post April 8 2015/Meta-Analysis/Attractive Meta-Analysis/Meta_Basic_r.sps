*******************************************************************.
*   Field, A. & Gillett, R. (2009).   "How To Do Meta-Analysis".
*   British Journal of Mathematical and Statistical Psychology.
*******************************************************************.
set printback=none.
dataset name original.
cd  "C:\Users\Sean Mackinnon\Desktop\OSCMplus\Hypothesis Testing\Meta-Analysis".
matrix.
* input variables.
get r /variables = r.
get n /variables = n.
* get number of studies (k) from number of rows in r-vector.
compute k = nrow(r).
* obtain adjusted values of r  (Overton, 1998, page 358). 
compute ar = r - (r&*(1-r&**2))&/(2*(n-3)).
* create zr, Fisher's z-transformation of r.
compute zr = 0.5*ln((1+r)&/(1-r)).
* zr has variance = 1/(n-3)  (Field, 2001, page 164).
compute v = 1/(n-3).
* create fixed-effects weight vector.
compute w = 1/v.
* sum weights.
compute sw = csum(w).
* calculate c  (Hedges & Vevea, 1998, equation 10).
compute c = sw - t(w)*w/sw.
* calculate Q  (H & V equation 7).
compute q = t(w)*zr&**2 - (t(w)*zr)**2/sw.
* variance component tau is set equal to zero if Q < k-1,  and to  (q-k+1)/c  otherwise.
compute tau = mmax({0, (q-k+1)/c}).
* variance of effect size under random-effects model.
compute vt = v + tau.
* random-effects weight vector (H & V equation 13).
compute wt = 1/vt.
* sum weights.
compute swt = csum(wt).
* calculate Q for R-E.
compute qe = t(wt)*zr&**2 - (t(wt)*zr)**2/swt.

print /title = "**********   META-ANALYSIS OF CORRELATION COEFFICIENTS:  r   **********".
print {k}/clabels=k/format=f9.0/title = "NUMBER OF STUDIES".

* obtain weighted means (based on zr) for F-E and R-E models. 
compute mean = {t(w)*zr/sw; t(wt)*zr/swt}.
* calculate standard errors and confidence intervals for means. 
compute sem = {sqrt(1/sw); sqrt(1/swt)}.
compute ci = {mean - 1.96*sem, mean + 1.96*sem}.
* convert means and confidence intervals (based on zr) back to r.
compute rmean = (exp(2*mean)-1)&/(exp(2*mean)+1).
compute rci = (exp(2*ci)-1)&/(exp(2*ci)+1).
compute zscore = abs(mean&/sem).
compute pz = 2*(1 - cdfnorm(zscore)).
* calculate fsn (Rosenthal Fail-Safe N).
compute sezr = {sqrt(v), sqrt(vt)}.
compute fsn = (t(zr)*sqrt(n-3))**2/2.706 - k.
* standardise zr values across studies for F-E and R-E models ( Begg & Mazumdar, 1994).
compute vtilde = {v - 1/sw, vt - 1/swt}.
compute u = make(k,1,1).
compute zrstar = (zr*{1,1} - u*t(mean))&/sqrt(vtilde).

* Hunter-Schmidt random-effects analysis.
compute rav = csum(n&*ar)/csum(n).
compute sr2 = csum(n&*((ar-rav)&**2))/csum(n).
compute se2 = (1-rav**2)**2/((csum(n)/k)-1).
compute vrho = sr2-se2.
compute sdrho = sqrt(vrho).
compute ciu = rav + (1.96*sdrho).
compute cil = rav - (1.96*sdrho).
compute chi = csum((n-1)&*(ar-rav)&**2)/(1-rav**2)**2.
compute chisig = 1 - chicdf(chi, k-1).

print /title = "**********   FIXED-EFFECTS MODEL   **********".
print {rmean(1), rci(1,1), rci(1,2), zscore(1), pz(1), k}/clabels='Mean r', 'Lower r', 'Upper r', z, p, k/format=f9.3/title='MEAN EFFECT SIZE, LOWER & UPPER 95% CONFIDENCE BOUNDS, AND Z-TEST '.
print {q, k-1, 1-chicdf({q}, k-1)}/clabels=Chi2, df,p/format=f9.3/title = "HOMOGENEITY TEST:  Q STATISTIC  (Goodness of Fit)".

print /title = "**********   HEDGES-VEVEA RANDOM-EFFECTS MODEL   **********".
print {rmean(2), rci(2,1), rci(2,2), zscore(2), pz(2), k}/clabels='Mean r', 'Lower r', 'Upper r', z, p, k/format=f9.3/title='MEAN EFFECT SIZE, LOWER & UPPER 95% CONFIDENCE BOUNDS, AND Z-TEST '.
print {tau}/clabels=Tau/format=f9.4 /title = "Estimated Variance in Population (Fisher-Transformed) Correlations".
print {qe, k-1, 1-chicdf({qe}, k-1)}/clabels=Chi2, df,p/format=f9.3/title = "HOMOGENEITY TEST:  Q STATISTIC  (Goodness of Fit)".

print /title = "**********   HUNTER-SCHMIDT RANDOM-EFFECTS MODEL   **********".
print {rav, cil, ciu, chi, chisig, (k-1)}/clabels='Mean r', 'Lower r', 'Upper r', Chi2, p, df/format=f9.3/title='MEAN EFFECT SIZE, LOWER & UPPER 95% CREDIBILITY BOUNDS, AND CHI-SQUARE TEST '.
print sr2 /format= f9.4 /title = "Sample Correlation Variance".
print se2 /format= f9.4 /Title = "Sampling Error Variance".
print vrho /format= f9.4 /title = "Estimated Variance in Population Correlations".

print /title = "**********   PUBLICATION BIAS DIAGNOSTIC INDICATORS   **********".
print fsn /format=f9.0/title 'Rosenthal Fail-Safe N'.
save {r, zr, v, zrstar, sezr, n} /outfile = 'Pub_Bias_Data.sav' /variables = r, zr, v, zrstar1, zrstar2, sezr1, sezr2, n. 
end matrix.

get file = 'Pub_Bias_Data.sav'.
dataset name pubbias. 
dataset activate pubbias. 

formats r zr zrstar1 zrstar2 sezr1 sezr2 (f8.3) n (F8.0).
variable labels
r 'Effect Size r'
zr 'Effect size zr (Fisher-Transformed r)'
zrstar1 'Effect Size zr (Standardised Across Studies)'
zrstar2 'Effect Size zr (Standardised Across Studies)'
sezr1 'Standard Error of zr'
sezr2 'Standard Error of zr'
n 'Sample Size'.

Title 'Funnel Plot  (Fixed-Effects Model)'.
GRAPH
  /SCATTERPLOT(BIVAR)=zr WITH sezr1
  /TITLE='Funnel Plot of Effect Size vs. Standard Error  (Fixed-Effects Model)'.

Title 'Begg & Mazumdar Rank Correlation  (Fixed-Effects Model)'.
NONPAR CORR
  /VARIABLES=zrstar1 sezr1
  /PRINT=KENDALL TWOTAIL NOSIG.

Title 'Funnel Plot  (Random-Effects Model)'.
GRAPH
  /SCATTERPLOT(BIVAR)=zr WITH sezr2
  /TITLE='Funnel Plot of Effect Size vs. Standard Error  (Random-Effects Model)'.

Title 'Begg & Mazumdar Rank Correlation  (Random-Effects Model)'.
NONPAR CORR
  /VARIABLES=zrstar2 sezr2
  /PRINT=KENDALL TWOTAIL NOSIG.

dataset activate original window=asis.
dataset close pubbias. 

*insert  file="Launch_Pub_Bias_r.sps".




