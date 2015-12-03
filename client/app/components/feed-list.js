import Ember from 'ember';
import ResizeAware from 'ember-resize/mixins/resize-aware';

export default Ember.Component.extend(ResizeAware, {
  debouncedDidResize() {
    var feedlist = this.$('.feed-list');
    feedlist.css('height', Ember.$(window).height() - feedlist.position().top);
  },

  init() {
    this._super();

    Ember.run.scheduleOnce('afterRender', this, function() {
      this.get('resizeService').trigger('debouncedDidResize');
    });
  },

  favoritesSelected: Ember.computed('selectedElement', function() {
    return this.get('selectedElement') === 'favorites';
  }),

  itemsSelected: Ember.computed('selectedElement', function() {
    return this.get('selectedElement') === 'items';
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
