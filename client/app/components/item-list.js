import Ember from 'ember';
import ResizeAware from 'ember-resize/mixins/resize-aware';
import KeyboardShortcuts from 'ember-keyboard-shortcuts/mixins/component';

export default Ember.Component.extend(ResizeAware, KeyboardShortcuts, {
  filters: Ember.inject.service('item-filters'),
  events: Ember.inject.service('events'),

  selectedItem: null,

  keyboardShortcuts: {
    'j' : {action: 'nextItem', global: false},
    'k' : {action: 'previousItem', global: false},
    'n' : {action: 'displayCurrentItem', global: false},
  },

  _resizeListener: null,
  _scrollListener: null,

  _nextItemHandler() {
    this.send('nextItem');
  },

  _previousItemHandler() {
    this.send('previousItem');
  },

  filteredItems: Ember.computed.filter('model', function(item) {
    return this.get('filters').filterItem(item);
  }),

  itemsSorting: ['date:desc', 'id:asc'],
  sortedItems: Ember.computed.sort('filteredItems', 'itemsSorting'),

  filterChange: Ember.observer('filters.selectedElement', function() {
    this.send('selectItem', null);
  }),

  onResize() {
    var itemlist = Ember.$('#item-list');
    var w = Ember.$(window);
    itemlist.css('height', w.height() - itemlist.position().top);
  },

	onScroll() {
		var elem = Ember.$('#item-list').eq(0);
		if(elem[0].scrollHeight - elem.scrollTop() <= elem.outerHeight()+200) {
			this.sendAction('onLoadMore');
		}
	},
  onScrollThrottled() {
    Ember.run.throttle(this, this.onScroll, 100, false);
  },

  didInsertElement() {
    this._resizeListener = Ember.run.bind(this, this.onResize);
    Ember.$(window).bind('resize', this._resizeListener);

    this._scrollListener = Ember.run.bind(this, this.onScrollThrottled);
    Ember.$('#item-list').bind('scroll', this._scrollListener);

    this.get('events')
      .on('nextItem', this, this._nextItemHandler)
      .on('previousItem', this, this._previousItemHandler);

    this.onResize();
  },

  didRender() {
    // Redo scroll event on update to check if we need to load more data.
    this.onScrollThrottled();
  },

  willRemoveElement() {
    Ember.$(window).unbind('resize', this._resizeListener);
    Ember.$('#item-list').unbind('scroll', this._scrollListener);

    this.get('events')
      .off('nextItem', this, this._nextItemHandler)
      .off('previousItem', this, this._previousItemHandler);

    this.send('selectItem', null);
  },

  actions: {
    selectItem(item) {
      var selected = this.get('selectedItem');
      if(selected) {
        selected.set('open', false);
      }

      this.set('selectedItem', item);

      if(item !== null && selected !== item) {
        item.set('open', true);
        item.set('read', true);
        if(item.get('hasDirtyAttributes')) {
          item.save();
        }
      }
    },

    nextItem() {
      var selected = this.get('selectedItem');
      var itemList = this.get('sortedItems');
      var item = itemList[itemList.indexOf(selected)+1];
      if(item) {
        this.send('selectItem', item);
      }
    },

    previousItem() {
      var selected = this.get('selectedItem');
      var itemList = this.get('sortedItems');
      var item = itemList[itemList.indexOf(selected)-1];
      if(item) {
        this.send('selectItem', item);
      }
    },

    displayCurrentItem() {
      if(this.get('selectedItem')) {
        window.open(this.get('selectedItem.url'), '_blank');
      }
    },
  }
});
