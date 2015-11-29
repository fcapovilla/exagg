import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return Ember.RSVP.hash({
      feed: this.store.peekRecord('feed', params.feed_id),
      items: this.store.query('item', {feed_id: params.feed_id, limit: 20})
    });
  },

  setupController(controller, model) {
    this.controllerFor('index').set('selectedElement', model.feed);
  },

  renderTemplate: function(controller, model) {
    this.render('item-list', {
      controller: 'itemList',
      model: model.items
    });
  }
});
