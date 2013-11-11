<result>
{
	for $x in /site/people/person/address,
	$y in $x/country,
	$z in /site/closed_auctions/closed_auction/buyer

	where $y = "United States"
	and 	
	$x/../@id [not (. = $z/@person)]

	return $x/../name
}
</result>
