//from http://www.bennadel.com/blog/1727-Viewing-jQuery-DOM-Event-Bindings-With-FireBug.htm
var counter = 1;
 
// Find all of the items on the page that
// have events attached to them. We will
// use advanced filtering to get this.

jQuery( "*" )
.filter(function(){
// Return only items that have the
// events data item.
return( jQuery( this ).data( "events" ) );
})
.css( "background-color", "gold" )
.each(
function(){
jQuery( this ).addClass( "evt" + counter++ );
}
);

//reveal events on e.g. the 15 counted object
jQuery( ".evt15" ).data( "events" );
