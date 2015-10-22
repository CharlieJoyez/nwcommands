*! Date        : 15oct2015
*! Version     : 2.0
*! Author      : Thomas Grund, University College Dublin
*! Email	   : thomas.u.grund@gmail.com

capture program drop nw_syntax
program nw_syntax
	syntax [anything],[max(integer 1) min(passthru) nocurrent name(string)]
	unw_defs

	if "`name'" == "" {
		local name = "netname"
	}
	if "`nodes'" == "" {
		local nodes = "nodes"
	}
	if "`networks'" == "" {
		local networks = "networks"
	}
	if "`directed'" == "" {
		local directed = "directed"
	}
	
	if "`id'" == "" {
		local id = "id"
	}
	
	if "`netobj'" == "" {
		local netobj = "netobj"
	}

	if "`anything'" == ""  & "`current'" == ""{
		capture mata: st_local("_temp", `nws'.get_current_name())
		capture mata: st_numscalar("r(id)",`nws'.get_index_of_current())
	}
	else {
		capture nwunab _temp : `anything', max(`max') `min'
		local networks_count : word count `_temp'
		capture local lastnet : word `networks_count' of `_temp'
		mata: st_numscalar("r(id)", first_index_match(`nws'.names, "`lastnet'"))
	}
	
	if _rc != 0 {
		di "{err}Network not found"
	    error `errNWsNotFound'
	}

	c_local `netobj' "`nws'.pdefs[`r(id)']"
	c_local `id' `r(id)'
	c_local `name' `_temp'
	c_local `networks' `networks_count'	
end
