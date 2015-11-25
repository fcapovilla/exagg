import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    saveFolder() {
      this.model.save();
    }
  }
});
