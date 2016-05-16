import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return this.store.createRecord('feed', {
      position: 1
    });
  },
});
