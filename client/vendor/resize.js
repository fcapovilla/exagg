// Resize the lists on viewport size changes
$(window).on('resize orientationChanged', function() {
	var itemlist = $('#item-list');
	var feedlist = $('.feed-list');

  if(!itemlist || !feedlist) {
    return;
  }

	if($(window).width() <= 767) {
		feedlist.css('height', $(window).height() - feedlist.position().top);
		itemlist.css('height', $(window).height() - itemlist.position().top);
	}
	else {
		feedlist.css('height', $(window).height() - feedlist.position().top);
		itemlist.css('height', $(window).height() - itemlist.position().top);
	}
});
