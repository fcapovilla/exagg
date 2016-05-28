import Ember from 'ember';

export default Ember.Component.extend({
  filters: Ember.inject.service('item-filters'),

  _resizeListener: null,

  folderSorting: ['position'],
  sortedFolders: Ember.computed.sort('model', 'folderSorting'),

  onResize() {
    var feedlist = Ember.$('.feed-list');
    var w = Ember.$(window);
    feedlist.css('height', w.height() - feedlist.position().top);
  },

  didInsertElement() {
    this._resizeListener = Ember.run.bind(this, this.onResize);
    Ember.$(window).bind('resize', this._resizeListener);

    this.onResize();
  },

  willRemoveElement() {
    Ember.$(window).unbind('resize', this._resizeListener);
  },

  favoritesSelected: Ember.computed('filters.selectedElement', function() {
    return this.get('filters.selectedElement') === 'favorites';
  }),

  itemsSelected: Ember.computed('filters.selectedElement', function() {
    return this.get('filters.selectedElement') === 'items';
  }),

  totalUnreadCount: Ember.computed('model.@each.unreadCount', function() {
    return this.model.reduce(function(acc, folder) {
      return acc + folder.get('unreadCount');
    }, 0);
  }),

  actions: {
    selectModel(model) {
      if(typeof model === 'string') {
        this.sendAction('onSelect', model);
      }
      else {
        this.sendAction('onSelect', model);
      }
    },

    editModel(model) {
      this.sendAction('onEdit', model);
    }
  }
});
