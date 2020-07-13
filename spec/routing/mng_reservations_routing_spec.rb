require "rails_helper"

RSpec.describe MngReservationsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/mng_reservations").to route_to("mng_reservations#index")
    end

    it "routes to #new" do
      expect(get: "/mng_reservations/new").to route_to("mng_reservations#new")
    end

    it "routes to #show" do
      expect(get: "/mng_reservations/1").to route_to("mng_reservations#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/mng_reservations/1/edit").to route_to("mng_reservations#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/mng_reservations").to route_to("mng_reservations#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/mng_reservations/1").to route_to("mng_reservations#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/mng_reservations/1").to route_to("mng_reservations#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/mng_reservations/1").to route_to("mng_reservations#destroy", id: "1")
    end
  end
end
