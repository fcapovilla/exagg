import Ember from 'ember';

export default Ember.Controller.extend({
  actions: {
    saveFolder() {
      var that = this;
      this.model.save().then(function(folder) {
        that.transitionToRoute('folder', folder.id);
      });
    }
  }
});
