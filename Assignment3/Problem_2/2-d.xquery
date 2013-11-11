<result>
{
	for $x in /site/closed_auctions/closed_auction
	where $x/price < 10
	return ./$x/buyer
}
</result>
