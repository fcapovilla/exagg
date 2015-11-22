import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.findRecord('feed', params.feed_id);
  },

  setupController(controller, feed) {
    this._super(controller, feed);
    this.controllerFor('index').set('selectedElement', feed);
  }
});
