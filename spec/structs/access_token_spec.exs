defmodule AccessTokenStructSpec do
  use ESpec

  describe "#valid?" do
    subject do: Clarifai.Structs.AccessToken.valid?(access_token())

    context "without a token" do
      let access_token: nil

      it do: should(be_false())
    end

    context "with a token" do
      let access_token: %Clarifai.Structs.AccessToken{value: "test_token", expires_in: expires_in()}

      context "when expired" do
        let expires_in: (DateTime.utc_now |> DateTime.to_unix) - 60

        it do: should(be_false())
      end

      context "when token value is nil" do
        let access_token: %Clarifai.Structs.AccessToken{value: nil}

        it do: should(be_false())
      end

      context "when valid" do
        let expires_in: (DateTime.utc_now |> DateTime.to_unix) + 60

        it do: should(be_true())
      end
    end
  end
end
