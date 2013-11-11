<result>
{
	for $x in /site/open_auctions/open_auction/bidder//personref
	where (some $item in $x/site/open_auctions/open_auction/itemref[text] satisfies
		contains(string($item), "cow"))
	return $x/@person
}
</result>
