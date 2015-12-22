import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'tr',
  classNameBindings: ['model.hasDirtyAttributes:warning'],

  actions: {
    deleteUser() {
      this.model.deleteRecord();
    },

    undo() {
      this.model.rollbackAttributes();
    }
  }
});
