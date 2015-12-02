import Ember from 'ember';

export default Ember.Controller.extend({
  selectedItem: null,

  itemsSorting: ['date:desc'],
  sortedItems: Ember.computed.sort('model', 'itemsSorting'),

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
    }
  }
});
