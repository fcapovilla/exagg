import Ember from 'ember';

export default Ember.Controller.extend({
  folderTitle: function() {
    return this.model.get('folder.title');
  }.property('model.folder.title'),

  actions: {
    saveFeed() {
      this.store.queryRecord('folder', {filter: {title: this.get('folderTitle')}}).then(function(folder) {
        if(folder === null) {
          folder = this.store.createRecord('folder', {
            title: this.get('folderTitle')
          });
        }
        this.model.set('folder', folder);
      });

      this.model.save();
    }
  }
});
