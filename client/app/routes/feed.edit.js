import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.findRecord('feed', params.feed_id);
  },
});
