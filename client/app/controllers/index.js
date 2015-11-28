import Ember from 'ember';

export default Ember.Controller.extend({
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
        this.transitionToRoute(model);
      }
      else {
        this.transitionToRoute(model.get('constructor.modelName'), model.get('id'));
      }
    },

    editModel(model) {
      this.transitionToRoute(model.get('constructor.modelName') + '.edit', model);
    },

    addFeed() {
      this.transitionToRoute('feed.new');
    }
  }
});
