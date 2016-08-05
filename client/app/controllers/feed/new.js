import Ember from 'ember';

export default Ember.Controller.extend({
  folderTitle: "",

  actions: {
    saveFeed() {
      var that = this;
      this.store.query('folder', {filter: {title: this.get('folderTitle')}}).then(function(folders) {
        var folder = folders.get('firstObject');

        // Create folder if it doesn't exist.
        if(!folder) {
          folder = that.store.createRecord('folder', {
            title: that.get('folderTitle'),
            position: 1
          });
        }

        folder.save().then(function() {
          that.model.set('folder', folder);
          that.model.save().then(function(feed) {
            that.transitionToRoute('feed', feed.id);
          });
        });
      });
    }
  }
});
