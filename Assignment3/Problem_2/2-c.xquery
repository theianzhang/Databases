<result>
{
	for $x in /site/people/person/address
	where $x/zipcode='27'
	return $x/zipcode/../../name
}
</result>
