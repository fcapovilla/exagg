import Ember from 'ember';

export default Ember.Component.extend({
  actions: {
    addUser() {
      var store = this.get('targetObject.store');
      store.createRecord('user', {});
    },

    save() {
      this.model.forEach(function(user) {
        if(user.get('hasDirtyAttributes')) {
          user.save();
        }
      });
    },

    cancel() {
      this.model.forEach(function(user) {
        if(user.get('hasDirtyAttributes')) {
          user.rollbackAttributes();
        }
      });
    }
  }
});
