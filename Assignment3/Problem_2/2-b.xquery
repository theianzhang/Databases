<result>
{
	for $x in /site/regions/*/item
	where $x//incategory[@category='category2']
	return $x/name
}
</result>
