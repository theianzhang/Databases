<result>
{
	declare function local:passthru($nodes as node()*) as item()* {
	    for $node in $nodes/node() return local:dispatch($node)
	};

	declare function local:dispatch($node as node()) as item()* {
	    typeswitch($node)
		case element(term) return local:term($node)
		case element(relative) return local:relative($node)
		default return local:passthru($node)
	};

	declare function local:term($node as element(bill)) as element() {
	    <term id="/term/termId name=termName type=termTy[e">{local:passthru($node)}</term>
	};

	declare function local:relative($node as element(btitle)) as element() {
	    <relative type="relativeType term=termId">{local:passthru($node)}</relative>
	};
}
</result>
