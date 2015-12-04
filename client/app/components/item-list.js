import Ember from 'ember';
import ResizeAware from 'ember-resize/mixins/resize-aware';
import KeyboardShortcuts from 'ember-keyboard-shortcuts/mixins/component';

export default Ember.Component.extend(ResizeAware, KeyboardShortcuts, {
  selectedItem: null,

  keyboardShortcuts: {
    'j' : 'nextItem',
    'k' : 'previousItem',
  },

  itemsSorting: ['date:desc'],
  sortedItems: Ember.computed.sort('model', 'itemsSorting'),

  /*
  debouncedDidResize() {
    var itemlist = Ember.$('#item-list');
    itemlist.css('height', Ember.$(window).height() - itemlist.position().top);
  },
  */

  modelChange: Ember.observer('model', function() {
    this.send('selectItem', null);
  }),

  willDestroy() {
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

    infinityLoad() {
      this.sendAction('infinityLoad');
    }
  }
});
