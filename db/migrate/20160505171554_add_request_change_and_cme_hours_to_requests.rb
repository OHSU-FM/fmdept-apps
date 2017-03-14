class AddRequestChangeAndCmeHoursToRequests < ActiveRecord::Migration
  def change
    add_column :leave_requests, :hours_cme, :decimal, :precision => 5,
        :scale => 2, :default => 0
    add_column :leave_requests, :request_change, :text
    add_column :travel_requests, :request_change, :text
  end
end
