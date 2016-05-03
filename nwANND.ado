*! Date        : 21avr2016
*! Version     : 1.2.0
*! Author      : Charlie Joyez, Paris-Dauphine University
*! Email	   : charlie.joyez@dauphine.fr

*Last modification : introduces WANND for weighted networks.
*Standardized strength : divided by the greatest strength.

*REQUIRES THE NWCOMMANDS PACKAGE BY T.GRUND (https://nwcommands.wordpress.com/)
* Calculates node's average nearest neighbor degree
* See A. Barrat, M. Barthélemy, R. Pastor-Satorras, and A. Vespignani, “The architecture of complex weighted networks”. PNAS 101 (11): 3747–3752 (2004).

capture program drop nwANND
program nwANND
	version 9
	syntax [anything(name=netname)]	[, VALued DIRection(string) standardize *]	
	_nwsyntax `netname', max(9999)
	_nwsetobs
	
foreach v in _degree _strength _in_degree _out_degree _in_strength _out_strength{
	capture confirm variable `v'
if !_rc {
                      
					   rename `v' alr_`v'
               }
}
	
	if `networks' > 1 {
		local k = 1
	}
	_nwsetobs `netname'
	
	set more off
 quietly foreach netname_temp in `netname' {
 nwtomata `netname_temp', mat(mymat)

_nwsyntax `netname_temp' 
local nodes_temp `nodes' 
local directed `directed' 

  mata: neighbor = mymat:>0
  mata : D=colsum(neighbor)
  mata : D=D'


	
	if "`valued'" == ""{
			if "`directed'" == "true" {
				if "`direction'"!="inward"{
					capture drop _out_degree _in_degree
					quietly nwdegree `netname_temp'
					mata: Z=st_data(.,"_out_degree")
					mata: totdegreemat = neighbor*Z
						if "`standardize'" == "" {
							mata: ANNDmat=totdegreemat:/Z
						}
						if "`standardize'" != "" {
							mata: ANNDmat1=totdegreemat:/Z 
							mata: ANNDmat=ANNDmat1/(`nodes_temp'-1)
							replace _in_degree=_in_degree/(`nodes_temp'-1)
							replace _out_degree=_out_degree/(`nodes_temp'-1)
						}
					mata: st_matrix("ANND", ANNDmat)
					capture drop _out_ANND
					mata: resindex = st_addvar("float","_out_ANND")
					mata: st_store((1,rows(ANNDmat)),resindex,ANNDmat)
					qui count if _out_ANND!=.
				
					noi di "{hline 40}"
					noi di "{txt}Network {res}`netname_temp' {txt} "
					noi di"{res}  `r(N)' {txt} real values of {res}`standardize' {txt}_out_ANND created"
					quie corr _out_degree _out_ANND 
					noi di  "{txt} inward assortativity coefficient :{res} `r(rho)'"
				}
				if "`direction'"=="inward"{
					capture drop _out_degree _in_degree
					quietly nwdegree `netname_temp'
					mata: Z=st_data(.,"_in_degree")
					mata: totdegreemat = neighbor*Z
						if "`standardize'" == "" {
							mata: ANNDmat=totdegreemat:/Z
						}
						if "`standardize'" != "" {
							mata: ANNDmat1=totdegreemat:/Z 
							mata: ANNDmat=ANNDmat1/(`nodes_temp'-1)
							replace _in_degree=_in_degree/(`nodes_temp'-1)
							replace _out_degree=_out_degree/(`nodes_temp'-1)
						}
					mata: st_matrix("ANND", ANNDmat)
					capture drop _in_ANND
					mata: resindex = st_addvar("float","_in_ANND")
					mata: st_store((1,rows(ANNDmat)),resindex,ANNDmat)
					qui count if _in_ANND!=.
				
					noi di "{hline 40}"
					noi di "{txt}Network {res}`netname_temp' {txt} "
					noi di "{res}  `r(N)' {txt} real values of {res}`standardize' {txt}_in_ANND created"
					quie corr _in_degree _in_ANND 
					noi di "{txt} inward assortativity coefficient :{res} `r(rho)'"
				}
				
			}
		   if "`directed'" != "true" {
				capture drop _degree
				quietly nwdegree `netname_temp'
				mata: Z=st_data(.,"_degree")
				mata: totdegreemat = neighbor*Z
					if "`standardize'" == "" {
						mata: ANNDmat=totdegreemat:/Z
					}
					if "`standardize'" != "" {
						mata: ANNDmat1=totdegreemat:/Z 
						mata: ANNDmat=ANNDmat1/(`nodes_temp'-1)
						replace _degree=_degree/(`nodes_temp'-1)
					}
				
				mata: st_matrix("ANND", ANNDmat)
				capture drop _ANND
				mata: resindex = st_addvar("float","_ANND")
				mata: st_store((1,rows(ANNDmat)),resindex,ANNDmat)
				qui count if _ANND!=.
				
				noi di "{hline 40}"
				noi di "{txt}Network {res}`netname_temp' {txt} "
				noi di "{res}  `r(N)' {txt} real values of {res}`standardize' {txt}_ANND created"
				quie corr _degree _ANND 
				noi di "{txt}assortativity coefficient :{res} `r(rho)'"
			}
	}
	if "`valued'" != ""{  
			if "`directed'" == "true" {
				if "`direction'"!="inward"{
					capture drop _out_strength _in_strength _out_degree _in_degree
					quietly nwdegree `netname_temp'
					quietly nwdegree `netname_temp',valued
					mata: Z=st_data(.,"_out_strength")
					mata: totstrengthmat=mymat*Z
					mata : D=st_data(.,"_out_degree")
					if "`standardize'" == "" {
							mata: WANNDmat=totstrengthmat:/Z
							mata: ANNSmat=totstrengthmat:/D
						}
						if "`standardize'" != "" {
							mata: ANNSmat1=totstrengthmat:/Z 
							mata: ANNSmat=ANNSmat1/(`nodes_temp'-1)
							replace _in_strength=_in_strength/(`nodes_temp'-1)
							replace _out_strength=_out_strength/(`nodes_temp'-1)
							su _out_strength
							local ms r(max) 
							replace _out_strength=_out_strength/(`nodes_temp'-1)
							replace _out_strength=_out_strength/`ms'
						}
						
					mata: st_matrix("WANND", WANNDmat)
					capture drop _out_WANND
					mata: resindex = st_addvar("float","_out_WANND")
					mata: st_store((1,rows(WANNDmat)),resindex,WANNDmat)
					qui count if _out_WANND!=.	
					
					noi di "{hline 40}"
					noi di "{txt}Network {res}`netname_temp' {txt} "
					noi di "{res}  `r(N)' {txt} real values of {res}`standardize' {txt} _out_WANND created"
					quie corr _out_degree _out_WANND
					noi di "{txt}outward weighted degree assortativity coefficient :{res} `r(rho)'"
					
					
					mata: st_matrix("ANNS", ANNSmat)
					capture drop _out_ANNS
					mata: resindex = st_addvar("float","_out_ANNS")
					mata: st_store((1,rows(ANNSmat)),resindex,ANNSmat)
					qui count if _out_ANNS!=.	
					
					noi di "{hline 40}"
					noi di "{txt}Network {res}`netname_temp' {txt} "
					noi di "{res}  `r(N)' {txt} real values of {res}`standardize' {txt} _out_ANNS created"
					quie corr _out_strength _out_ANNS
					noi di "{txt}outward strength assortativity coefficient :{res} `r(rho)'"
				}
			if "`direction'"=="inward"{
					capture drop _out_strength _in_strength _out_degree _in_degree
					quietly nwdegree `netname_temp'
					quietly nwdegree `netname_temp',valued
					mata: Z=st_data(.,"_in_strength")
					mata: totstrengthmat=mymat*Z
					mata : D=st_data(.,"_in_degree")
						if "`standardize'" == "" {
							mata: WANNDmat=totstrengthmat:/Z
							mata: ANNSmat=totstrengthmat:/D
						}
						if "`standardize'" != "" {
							mata: ANNSmat1=totstrengthmat:/Z 
							mata: ANNSmat=ANNSmat1/(`nodes_temp'-1)
							replace _in_strength=_in_strength/(`nodes_temp'-1)
							replace _out_strength=_out_strength/(`nodes_temp'-1)
							su _in_strength
							local ms r(max) 
							replace _in_strength=_in_strength/(`nodes_temp'-1)
							replace _in_strength=_in_strength/`ms'
						}
					
					mata: st_matrix("WANND", WANNDmat)
					capture drop _in_WANND
					mata: resindex = st_addvar("float","_in_WANND")
					mata: st_store((1,rows(WANNDmat)),resindex,WANNDmat)
					qui count if _in_WANND!=.	
					
					noi di "{hline 40}"
					noi di "{txt}Network {res}`netname_temp' {txt} "
					noi di "{res}  `r(N)' {txt} real values of {res}`standardize' {txt} _in_WANND created"
					quie corr _in_degree _in_WANND
					noi di "{txt}inward weighted degree assortativity coefficient :{res} `r(rho)'"
					
					
					mata: st_matrix("ANNS", ANNSmat)
					capture drop _in_ANNS
					mata: resindex = st_addvar("float","_in_ANNS")
					mata: st_store((1,rows(ANNSmat)),resindex,ANNSmat)
					qui count if _in_ANNS!=.	
					
					noi di "{hline 40}"
					noi di "{txt}Network {res}`netname_temp' {txt} "
					noi di "{res}  `r(N)' {txt} real values of {res}`standardize' {txt} _in_ANNS created"
					quie corr _in_strength _in_ANNS
					noi di "{txt}inward strength assortativity coefficient :{res} `r(rho)'"
				}
			
			}
					
		if "`directed'" != "true" {
				capture drop _strength _degree
				quietly nwdegree `netname_temp'
				quietly nwdegree `netname_temp',valued
				mata: Z=st_data(.,"_strength")
				mata: totstrengthmat=mymat*Z
				mata : D=st_data(."_degree")
					if "`standardize'" == "" {
							mata: WANNDmat=totstrengthmat:/Z
							mata: ANNSmat=totstrengthmat:/D
						}
						if "`standardize'" != "" {
							mata: ANNSmat1=totstrengthmat:/Z 
							mata: ANNSmat=ANNSmat1/(`nodes_temp'-1)					
							su _strength
							local ms r(max) 
							replace _strength=_strength/(`nodes_temp'-1)
							replace _strength=_strength/`ms'
						}
				
				mata: st_matrix("WANND", WANNDmat)
				capture drop _WANND
				mata: resindex = st_addvar("float","_WANND")
				mata: st_store((1,rows(WANNDmat)),resindex,WANNDmat)
				qui count if _WANND!=.
				
				noi di "{hline 40}"
				noi di "{txt}Network {res}`netname_temp' {txt} "
				noi di "{res}  `r(N)' {txt} real values of {res}`standardize' {txt} _WANND created"
				quie corr _degree _WANND
				noi di "{txt}weighted degree assortativity coefficient :{res} `r(rho)'"
				
				
				
				mata: st_matrix("ANNS", ANNSmat)
				capture drop _ANNS
				mata: resindex = st_addvar("float","_ANNS")
				mata: st_store((1,rows(ANNSmat)),resindex,ANNSmat)
				qui count if _ANNS!=.
				
				noi di "{hline 40}"
				noi di "{txt}Network {res}`netname_temp' {txt} "
				noi di "{res}  `r(N)' {txt} real values of {res}`standardize' {txt} _ANNS created"
				quie corr _strength _ANNS 
				noi di "{txt}strength assortativity coefficient :{res} `r(rho)'"
				
		}
	}
local k = `k' + 1
		
		
	
}
foreach v in _degree _strength _in_degree _out_degree _in_strength _out_strength{
	capture confirm variable alr_`v'
if !_rc {
          capture drop  `v'           
					  rename alr_`v' `v'

               }

			   else {

					capture drop `v'
			  
			   }
}
	end
