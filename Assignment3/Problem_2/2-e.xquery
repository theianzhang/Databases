<result>
{
	for $x in /site/people,
	$k in $x/person[@id],
	$y in /site/open_auctions/open_auction,
	$z in /site/regions/*

	where 
	(some $name in $z//item satisfies
	contains(string($name), 'cow'))
	and
	$k [(. = $y/bidder[@personref])]

	return $x/name
}
</result>
