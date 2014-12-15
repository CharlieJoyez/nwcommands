capture program drop nwds
program nwds, rclass
	 syntax [anything(name=netname)] , [alpha *]
	 if "`netname'" == "" {
		local netname = "_all"
	 }
	 _nwsyntax `netname', max(9999)
	 if "`alpha'" != "" {
		local netname : list sort netname
	 }
	 preserve
	 clear
	 foreach v in `netname' {
		gen `v' = .
	 }
	 ds `netname', `alpha' `options'
	 restore
	 return local netlist "`netname'"
end
